extends Node3D
class_name GameBase

@onready var in_game_menu: Control = %InGameMenu
@onready var main_ui_layer: CanvasLayer = %MainUILayer
@onready var doll_holder: DollHolder = %DollHolder
@onready var interact_ui: InteractUI = %InteractUI
@onready var sandbox_menu: PanelContainer = %SandboxMenu

var character_creator:Node

@onready var characterRegistry: CharacterRegistry = %CharacterRegistry
@onready var pawn_registry: PawnRegistry = %PawnRegistry
@onready var sit_manager: SitManager = %SitManager


func _init():
	GM.game = self
	GlobalRegistry.doInit()

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
	$TestAnimScene.setChar(thePC)
	
	
	
	#$WorldEnvironment.environment.sdfgi_enabled = false
	#$MainUILayer/TextureRect.texture = $MyLayeredTexture.getTexture()
	#$MyLayeredTexture.addColorMaskLayer(("res://icon.svg"), Color.RED, Color.YELLOW, Color.TRANSPARENT)
	#$MyLayeredTexture.addBlendAddLayer(("res://a1.png"))
	#$MyLayeredTexture.addBlendAddLayer(("res://a2.png"))

func hideAllMenus():
	in_game_menu.visible = false
	sandbox_menu.visible = false
	if(character_creator):
		character_creator.queue_free()
		character_creator = null

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("game_menu")):
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


func _on_sandbox_menu_on_close_pressed() -> void:
	sandbox_menu.visible = false

func _on_in_game_menu_on_sandbox_menu_button() -> void:
	hideAllMenus()
	sandbox_menu.visible = true
