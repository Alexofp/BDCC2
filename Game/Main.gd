extends Node3D
class_name MainScene

@onready var in_game_menu: Control = %InGameMenu
@onready var main_ui_layer: CanvasLayer = %MainUILayer
@onready var doll_holder: DollHolder = %DollHolder
@onready var interact_ui: InteractUI = %InteractUI
@onready var sandbox_menu: PanelContainer = %SandboxMenu

var character_creator:Node

@onready var characterRegistry: CharacterRegistry = %CharacterRegistry
@onready var pawn_registry: PawnRegistry = %PawnRegistry
@onready var sit_manager: SitManager = %SitManager
@onready var networked_nodes: NetworkedNodes = %NetworkedNodes
@onready var sex_manager: SexManager = %SexManager
@onready var character_menu: Control = %CharacterMenu
@onready var chat_widget_fullscreeen: Control = %ChatWidgetFullscreeen

@onready var sex_ui: SexUI = %SexUI

@onready var building_platform_8x_8: Node3D = %BuildingPlatform8x8

var interactionSystem:InteractionSystem

var gameMode:GameModeBase
var mapPath:String = ""

func loadModeOnMap(_map:String, _mode:int, _args:Array):
	mapPath = _map
	if(!GameMode.SCENES.has(_mode)):
		Log.Printerr("UNKNOWN GAME MODE: "+str(_mode))
	else:
		var theScene:PackedScene = load(GameMode.SCENES[_mode])
		var theMode:GameModeBase = theScene.instantiate()
		add_child(theMode)
		theMode.initArgs(_args)
		gameMode = theMode
	
	var theFuture := ThreadedResourceLoader.loadFuture(_map)
	await theFuture.task_completed
	var theMap:PackedScene = theFuture.get_result()#load(_map)
	var theMapNode:Node3D = theMap.instantiate()
	add_child(theMapNode)
	building_platform_8x_8.queue_free()

func startGame():
	if(gameMode):
		gameMode.start()

func _init():
	GM.main = self
	#GlobalRegistry.doInit()
	interactionSystem = InteractionSystem.new()

func _enter_tree() -> void:
	GM.main = self

func _exit_tree() -> void:
	if(GM.main == self):
		GM.main = null

func onMultiplayerPreStart(_isHost:bool):
	Log.Print("onMultiplayerStart(isHost="+str(_isHost)+")")
	if(!_isHost):
		characterRegistry.clearCharacters()
		pawn_registry.clearPawns()
		doll_holder.clearDolls()
	if(_isHost): # Makes it so you can figure out who is host/client by looking at the node tree
		var newNode:Node2D = Node2D.new()
		newNode.name = "HOOOOST"
		add_child(newNode)
	else:
		var newNode:Node2D = Node2D.new()
		newNode.name = "CLIENTTTTT"
		add_child(newNode)

func onMultiplayerStart(_isHost:bool):
	pass

func onPlayerConnected(_peer_id:int, _player_info:NetworkPlayerInfo):
	Log.Print("Player connected: "+_player_info.nickname+" (id="+str(_peer_id)+")")
	#if(Network.isServer()):
		#var thePC:BaseCharacter = characterRegistry.createCharacter()
		#var _thePawn:CharacterPawn = pawn_registry.createPawn(thePC.getID())
		#_player_info.charID = thePC.getID()
	if(gameMode):
		gameMode.onPlayerConnected(_peer_id, _player_info)
		
func onPlayerDisconnected(_peer_id:int, _player_info:NetworkPlayerInfo):
	#Log.Print("Player disconnected: "+_player_info.nickname+" (id="+str(_peer_id)+")")
	#if(Network.isServer()):
	#	pawn_registry.deletePawnOfNetworkPlayer(_player_info)
	if(gameMode):
		gameMode.onPlayerDisconnected(_peer_id, _player_info)
	pass

func _ready() -> void:
	hideAllMenus()
	sit_manager.connectSignals()
	Network.preMultiplayerStarted.connect(onMultiplayerPreStart)
	Network.multiplayerStarted.connect(onMultiplayerStart)
	Network.playerConnected.connect(onPlayerConnected)
	Network.playerDisconnected.connect(onPlayerDisconnected)

	#var thePC:BaseCharacter = characterRegistry.createCharacter()
	#var _thePawn:CharacterPawn = pawn_registry.createPawn(thePC.getID())
	#var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	#myInfo.charID = thePC.getID()

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
	chat_widget_fullscreeen.visible = !sex_ui.visible
	
	if(!UIHandler.isMenuInputBlocked()):
		if(Input.is_action_just_pressed("game_menu")):
			if(!UIHandler.tryCloseMenu()):
				in_game_menu.visible = true
			
		#if(Input.is_action_just_pressed("debug_mousecapture")):
			#if(!character_creator):
				#if(!UIHandler.tryCloseMenu()):
					#_on_in_game_menu_on_char_creator_button()
			#else:
				#onCharCreatorConfirmButton()
		if(Input.is_action_just_pressed("game_interact_menu") || Input.is_action_just_pressed("game_inventory")):
			if(!UIHandler.tryCloseMenu()):
				toggleCharacterMenu()

func _physics_process(_dt: float) -> void:
	interactionSystem.processInteractions(_dt)

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

func _on_in_game_menu_on_char_creator_button() -> void:
	hideAllMenus()
	showCharacterCreator()
	
func showCharacterCreator():
	if(character_creator != null && is_instance_valid(character_creator)):
		return
	
	character_creator = preload("res://Game/CharacterCreator/character_creator.tscn").instantiate()
	main_ui_layer.add_child(character_creator)
	
	character_creator.setCharacter(GM.pc)
	character_creator.onConfirmPressed.connect(onCharCreatorConfirmButton)
	
	#TODO: REMOVE THIS
	OPTIONS.triggerCharTextureQualityChange()
	if(gameMode):
		gameMode.onCharacterCreatorAppear()

func onCharCreatorConfirmButton():
	hideCharacterCreator()
	
func hideCharacterCreator():
	if(character_creator == null || !is_instance_valid(character_creator)):
		return
	character_creator.queue_free()
	character_creator = null
	if(gameMode):
		gameMode.onCharacterCreatorConfirm()

func isCharacterCreatorVisible() -> bool:
	if(character_creator == null || !is_instance_valid(character_creator)):
		return false
	return true

func _on_in_game_menu_on_exit_button() -> void:
	#get_tree().quit()
	GM.startMainMenu()

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

func getGameMode() -> GameModeBase:
	return gameMode
