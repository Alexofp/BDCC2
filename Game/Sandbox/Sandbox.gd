extends Node3D
class_name GameBase

@onready var in_game_menu: Control = %InGameMenu
@onready var main_ui_layer: CanvasLayer = %MainUILayer
@onready var doll_holder: DollHolder = %DollHolder
@onready var interact_ui: InteractUI = %InteractUI
@onready var sandbox_menu: PanelContainer = %SandboxMenu

var character_creator:Node
#var interaction_menu:Node
#var inventory_ui:Node

@onready var characterRegistry: CharacterRegistry = %CharacterRegistry
@onready var pawn_registry: PawnRegistry = %PawnRegistry
@onready var sit_manager: SitManager = %SitManager
@onready var networked_nodes: NetworkedNodes = %NetworkedNodes
@onready var sex_manager: SexManager = %SexManager
@onready var character_menu: Control = %CharacterMenu

@onready var sex_ui: SexUI = %SexUI

func _init():
	GM.game = self
	#GlobalRegistry.doInit()

func _enter_tree() -> void:
	GM.game = self

func _exit_tree() -> void:
	if(GM.game == self):
		GM.game = null

func onMultiplayerStart(_isHost:bool):
	Log.Print("onMultiplayerStart(isHost="+str(_isHost)+")")
	if(!_isHost):
		characterRegistry.clearCharacters()
		pawn_registry.clearPawns()
		doll_holder.clearDolls()
	if(_isHost):
		var newNode:Node2D = Node2D.new()
		newNode.name = "HOOOOST"
		add_child(newNode)
	else:
		var newNode:Node2D = Node2D.new()
		newNode.name = "CLIENTTTTT"
		add_child(newNode)

func onPlayerConnected(_peer_id:int, _player_info:NetworkPlayerInfo):
	Log.Print("Player connected: "+_player_info.nickname+" (id="+str(_peer_id)+")")
	if(Network.isServer()):
		var thePC:BaseCharacter = characterRegistry.createCharacter()
		var _thePawn:CharacterPawn = pawn_registry.createPawn(thePC.getID())
		_player_info.charID = thePC.getID()
		#thePawn.setPlayerID(_peer_id)
		
		
		#var _theDoll:DollController = doll_holder.createDollControllerFor(thePC, _peer_id)

func onPlayerDisconnected(_peer_id:int, _player_info:NetworkPlayerInfo):
	#Log.Print("Player disconnected: "+_player_info.nickname+" (id="+str(_peer_id)+")")
	if(Network.isServer()):
		pawn_registry.deletePawnOfNetworkPlayer(_player_info)
		#doll_holder.deleteDollsOfNetworkPlayerID(_peer_id)

func _ready() -> void:
	hideAllMenus()
	sit_manager.connectSignals()
	
	Network.multiplayerStarted.connect(onMultiplayerStart)
	Network.playerConnected.connect(onPlayerConnected)
	Network.playerDisconnected.connect(onPlayerDisconnected)
	
	var thePC:BaseCharacter = characterRegistry.createCharacter()
	var _thePawn:CharacterPawn = pawn_registry.createPawn(thePC.getID())
	var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	myInfo.charID = thePC.getID()
	#thePawn.grabControl()
	#doll_holder.createDollControllerFor(thePC).grabControl()
	#$TestAnimScene.setChar(thePC)
	
	
	var char2:BaseCharacter = characterRegistry.createCharacter()
	var _thePawn2:CharacterPawn = pawn_registry.createPawn(char2.getID())
	_thePawn2.position.x = 2.0
	
	#sex_manager.startSex(SexType.OnTheFloor, {dom=thePC.getID(), sub=char2.getID()}, {}, _thePawn.global_position, Vector3(0.0, 0.0, 0.0))
	
	#testFutures()
	#ThreadedResourceLoader.threadPool.task_completed.connect(onTaskCompleted)

#func onTaskCompleted(_theTask):
#	print("MEOW "+str(_theTask.result))

func testFutures():
	var theFuture := ThreadedResourceLoader.threadPool.submit_task_array_parameterized(self, "testThread", [RNG.randiRange(1, 10), RNG.randiRange(1, 10)])
	await theFuture.task_completed
	print("RESULT: "+str(theFuture.get_result()))
	#await ThreadedResourceLoader.threadPool.task_completed
	#var theResult:int = theFuture.get_result()
	#print("RESULT: "+str(theResult))

func testThread(_a:int, _b:int) -> int:
	for _i in range(1000000):
		var _asd = sqrt(_i)+sqrt(_i)+pow(_i, 0.1)
	return _a + _b

func hideAllMenus():
	in_game_menu.visible = false
	sandbox_menu.visible = false
	if(character_creator):
		character_creator.queue_free()
		character_creator = null
	#if(interaction_menu):
	#	interaction_menu.queue_free()
	#	interaction_menu = null
	hideCharacterMenu()
	#if(inventory_ui):
	#	inventory_ui.queue_free()
	#	inventory_ui = null

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("game_menu")):
		#testFutures()
		#return
		if(character_creator):
			return
		var newVis:bool = !in_game_menu.visible
		hideAllMenus()
		in_game_menu.visible = newVis
	if(Input.is_action_just_pressed("debug_mousecapture")):
		if(!character_creator):
			_on_in_game_menu_on_char_creator_button()
		else:
			onCharCreatorConfirmButton()
	if(Input.is_action_just_pressed("game_interact_menu") || Input.is_action_just_pressed("game_inventory")):
		toggleCharacterMenu()
		#if(!interaction_menu):
			#interaction_menu = preload("res://Game/CharacterCreator/InteractionMenu/interaction_menu.tscn").instantiate()
			#main_ui_layer.add_child(interaction_menu)
			#interaction_menu.onClose.connect(onInteractionMenuClosed)
			#interaction_menu.setCharacter(GM.pc)
		#else:
			#onInteractionMenuClosed()
	#if(Input.is_action_just_pressed("game_inventory")):
		#if(!inventory_ui):
			#inventory_ui = preload("res://Inventory/UI/inventory_test_ui.tscn").instantiate()
			#main_ui_layer.add_child(inventory_ui)
			##interaction_menu.onClose.connect(onInteractionMenuClosed)
			#inventory_ui.setInventory(GM.pc.inventory)
		#else:
			#onInventoryClosed()

func toggleCharacterMenu():
	if(character_menu.visible):
		hideCharacterMenu()
	else:
		showCharacterMenu()

func showCharacterMenu():
	if(character_menu.visible):
		return
	character_menu.visible = true
	character_menu.setCharacter(GM.pc)

func hideCharacterMenu():
	if(!character_menu.visible):
		return
	character_menu.visible = false
	character_menu.setCharacter(null)

#func onInventoryClosed():
	#if(inventory_ui):
		#inventory_ui.queue_free()
		#inventory_ui = null
	#
#func onInteractionMenuClosed():
	#if(interaction_menu):
		#interaction_menu.queue_free()
		#interaction_menu = null

func _on_in_game_menu_on_char_creator_button() -> void:
	hideAllMenus()
	if(character_creator != null && is_instance_valid(character_creator)):
		return
	
	character_creator = preload("res://Game/CharacterCreator/character_creator.tscn").instantiate()
	main_ui_layer.add_child(character_creator)
	
	character_creator.setCharacter(GM.pc)
	character_creator.onConfirmPressed.connect(onCharCreatorConfirmButton)

func onCharCreatorConfirmButton():
	if(character_creator == null || !is_instance_valid(character_creator)):
		return
	character_creator.queue_free()
	character_creator = null


func _on_in_game_menu_on_exit_button() -> void:
	get_tree().quit()

func getCharacterRegistry() -> CharacterRegistry:
	return characterRegistry

func getPawnRegistry() -> PawnRegistry:
	return pawn_registry

func getDollHolder() -> DollHolder:
	return doll_holder


func _on_doll_holder_on_current_doll_switch(_oldDoll: Variant, _newDoll: DollController) -> void:
	if(!_newDoll):
		interact_ui.setInteractorAndUser(null, null)
	else:
		interact_ui.setInteractorAndUser(_newDoll.getInteractor(), _newDoll)
	
	if(!Network.getMyPlayerInfo()):
		sex_ui.setPawn(null)
	else:
		var currentCharID:String = Network.getMyPlayerInfo().charID
		sex_ui.setPawn(GM.pawnRegistry.getPawn(currentCharID))

func _on_sandbox_menu_on_close_pressed() -> void:
	sandbox_menu.visible = false

func _on_in_game_menu_on_sandbox_menu_button() -> void:
	hideAllMenus()
	sandbox_menu.visible = true

func getSexManager() -> SexManager:
	return sex_manager

func _on_character_menu_on_close() -> void:
	hideCharacterMenu()
