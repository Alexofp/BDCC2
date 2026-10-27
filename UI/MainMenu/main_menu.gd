extends Control

const SCREEN_MAIN = 0
const SCREEN_MULTIPLAYER = 1
#const SCREEN_MULT_LAN = 2
#const SCREEN_MULT_NODETUNNEL = 3
const SCREEN_SETTINGS = 4
#const SCREEN_MULT_NORAY = 5
const SCREEN_START_GAME = 6
const SCREEN_LOAD_GAME = 7
const SCREEN_MULT_SETTINGS = 8

const BACKSCREENS = {
	SCREEN_MULTIPLAYER: SCREEN_MAIN,
	#SCREEN_MULT_LAN: SCREEN_MULTIPLAYER,
	#SCREEN_MULT_NORAY: SCREEN_MULTIPLAYER,
	SCREEN_MULT_SETTINGS: SCREEN_MULTIPLAYER,
}

var currentScreen:int = -1
var currentConnector:ConnectorNetworkBase

@onready var main_list: VBoxContainer = %MainList
@onready var multiplayer_list: VBoxContainer = %MultiplayerList

@onready var tools_container: PanelContainer = %ToolsContainer
@onready var settings_tab: MarginContainer = %SettingsTab
@onready var net_connector_list: VBoxContainer = %NetConnectorList
@onready var net_var_list: VarList = %NetVarList
@onready var net_join_list: VBoxContainer = %NetJoinList

@onready var controls_panel_container: PanelContainer = %ControlsPanelContainer
var startGameUI:StartGameUI
var loadGameUI:Control

func _ready() -> void:
	setScreen(SCREEN_MAIN)
	
	for theID:String in GlobalRegistry.networkConnectorRefs:
		var theConnector:ConnectorNetworkBase = GlobalRegistry.networkConnectorRefs[theID]
		var theButton:Button = Button.new()
		theButton.text = theConnector.getListName()
		net_connector_list.add_child(theButton)
		theButton.pressed.connect(onNetworkButtonPressed.bind(theID))

func onNetworkButtonPressed(_networkID:String):
	currentConnector = GlobalRegistry.createNetworkConnector(_networkID)
	setScreen(SCREEN_MULT_SETTINGS)

func setScreen(_screen:int):
	currentScreen = _screen
	main_list.visible = (_screen == SCREEN_MAIN)
	tools_container.visible = (_screen == SCREEN_MAIN)
	controls_panel_container.visible = (_screen == SCREEN_MAIN)
	multiplayer_list.visible = (_screen == SCREEN_MULTIPLAYER)
	settings_tab.visible = (_screen == SCREEN_SETTINGS)
	net_join_list.visible = (_screen == SCREEN_MULT_SETTINGS)
	
	if(_screen == SCREEN_MULT_SETTINGS):
		net_var_list.setVars(currentConnector.getJoinSettings() if currentConnector else {})
		
	if(_screen == SCREEN_START_GAME):
		if(!startGameUI):
			startGameUI = load("res://Game/UI/StartGameUI/StartGameUI.tscn").instantiate()
			add_child(startGameUI)
			startGameUI.onCancelPressed.connect(_on_start_game_ui_on_cancel_pressed)
			startGameUI.onStartPressed.connect(startGameUIStart)
	else:
		if(startGameUI):
			startGameUI.queue_free()
			startGameUI = null
	
	if(_screen == SCREEN_LOAD_GAME):
		if(!loadGameUI):
			loadGameUI = load("res://UI/LoadGameUI/LoadGameUI.tscn").instantiate()
			add_child(loadGameUI)
			loadGameUI.onBackPressed.connect(_on_load_game_ui_on_cancel_pressed)
			loadGameUI.onNewGamePressed.connect(setScreen.bind(SCREEN_START_GAME))
	else:
		if(loadGameUI):
			loadGameUI.queue_free()
			loadGameUI = null
	

func startGameUIStart(_start:StartGameHolder):
	GM.startNewGame(_start)

func _on_play_button_pressed() -> void:
	#GM.startGame_OLD("res://Maps/Prison/prison.tscn", GameMode.Sandbox)
	#GM.loadSavedGame("user://Game/Saves/test.save")
	setScreen(SCREEN_LOAD_GAME)

func _on_char_editor_button_pressed() -> void:
	GM.startGame_OLD("res://Maps/CharacterCreatorRoom/character_creator_room.tscn", GameMode.CharacterCreator)

func _on_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/IngameEditor/build_test.tscn")

func _on_preview_maker_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/PreviewMaker/preview_maker.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_multiplayer_button_pressed() -> void:
	setScreen(SCREEN_MULTIPLAYER)

func _on_back_button_pressed() -> void:
	setScreen(BACKSCREENS[currentScreen] if BACKSCREENS.has(currentScreen) else SCREEN_MAIN)

#func _on_lan_button_pressed() -> void:
#	setScreen(SCREEN_MULT_LAN)

#func _on_lan_host_button_pressed() -> void:
#	var theNickame:String = nickname_edit.text if nickname_edit.text else "Host"
#	
#	GM.hostLANGame(theNickame, "res://Maps/Prison/prison.tscn", GameMode.Sandbox)
	#GM.hostLANGame(theNickame, "res://Maps/CharacterCreatorRoom/character_creator_room.tscn", GameMode.CharacterCreator)

#func _on_lan_join_button_pressed() -> void:
#	var theNickame:String = nickname_edit.text if !nickname_edit.text.is_empty() else "Client"
#	var theIP:String = lan_ip_edit.text if !lan_ip_edit.text.is_empty() else "127.0.0.1"
#	
#	GM.joinLANGame(theNickame, theIP, lan_server_password.text)


func _on_settings_button_pressed() -> void:
	setScreen(SCREEN_SETTINGS)

func _on_settings_ui_on_cancel_pressed() -> void:
	_on_back_button_pressed()
func _on_settings_ui_on_save_pressed() -> void:
	_on_back_button_pressed()


#func _on_noray_host_button_pressed() -> void:
#	var theNickame:String = nickname_edit.text if nickname_edit.text else "Host"
#	var theRelayServer:String = noray_relay_server_edit.text if !noray_relay_server_edit.text.is_empty() else Network.NORAY_SERVER
#	
#	var ipPort := Util.separateIPPort(theRelayServer)
#	if(ipPort.size() == 1):
#		ipPort.append(Network.NORAY_PORT)
#	
#	GM.hostNoray(theNickame, "res://Maps/Prison/prison.tscn", GameMode.Sandbox, [], ipPort[0], ipPort[1])

#func _on_noray_join_button_pressed() -> void:
#	var theNickame:String = nickname_edit.text if !nickname_edit.text.is_empty() else "Client"
#	var theRoomID:String = noray_room_edit.text if !noray_room_edit.text.is_empty() else ""
#	var theRelayServer:String = noray_relay_server_edit.text if !noray_relay_server_edit.text.is_empty() else Network.NORAY_SERVER
#	
#	var ipPort := Util.separateIPPort(theRelayServer)
#	if(ipPort.size() == 1):
#		ipPort.append(Network.NORAY_PORT)
#	if(theRoomID.is_empty()):
#		return
#	GM.joinNorayGame(theNickame, theRoomID, ipPort[0], ipPort[1], true, noray_server_password.text)

#func _on_noray_tunnel_button_pressed() -> void:
#	setScreen(SCREEN_MULT_NORAY)

func _on_start_game_ui_on_cancel_pressed() -> void:
	setScreen(SCREEN_MAIN)
func _on_load_game_ui_on_cancel_pressed() -> void:
	setScreen(SCREEN_MAIN)

func _on_new_button_pressed() -> void:
	setScreen(SCREEN_START_GAME)

func _on_net_var_list_on_var_change(_id: String, value: Variant) -> void:
	if(!currentConnector):
		return
	if(currentConnector.applyJoinSetting(_id, value)):
		net_var_list.setVars(currentConnector.getJoinSettings())

func _on_join_button_pressed() -> void:
	if(!currentConnector):
		return
	GM.joinMultiplayerGame(currentConnector)
