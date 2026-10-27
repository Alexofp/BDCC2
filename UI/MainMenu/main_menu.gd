extends Control

const SCREEN_MAIN = 0
const SCREEN_MULTIPLAYER = 1
const SCREEN_MULT_LAN = 2
#const SCREEN_MULT_NODETUNNEL = 3
const SCREEN_SETTINGS = 4
const SCREEN_MULT_NORAY = 5
const SCREEN_START_GAME = 6
const SCREEN_LOAD_GAME = 7

const BACKSCREENS = {
	SCREEN_MULTIPLAYER: SCREEN_MAIN,
	SCREEN_MULT_LAN: SCREEN_MULTIPLAYER,
	SCREEN_MULT_NORAY: SCREEN_MULTIPLAYER,
}

var currentScreen:int = -1

@onready var main_list: VBoxContainer = %MainList
@onready var multiplayer_list: VBoxContainer = %MultiplayerList
@onready var lan_list: VBoxContainer = %LanList

@onready var nickname_edit: LineEdit = %NicknameEdit
@onready var lan_ip_edit: LineEdit = %LanIPEdit

@onready var tools_container: PanelContainer = %ToolsContainer
@onready var settings_tab: MarginContainer = %SettingsTab

@onready var lan_server_password: LineEdit = %LanServerPassword
@onready var noray_server_password: LineEdit = %NorayServerPassword

@onready var noray_tunnel_list: VBoxContainer = %NorayTunnelList
@onready var noray_room_edit: LineEdit = %NorayRoomEdit
@onready var noray_relay_bottom_list: VBoxContainer = %NorayRelayBottomList
@onready var noray_relay_server_edit: LineEdit = %NorayRelayServerEdit
@onready var noray_relay_list: OptionButton = %NorayRelayList
@onready var controls_panel_container: PanelContainer = %ControlsPanelContainer
var startGameUI:StartGameUI
var loadGameUI:Control

func _ready() -> void:
	setScreen(SCREEN_MAIN)
	
	noray_relay_server_edit.text = NorayNetworkConnector.NORAY_SERVER
	#LoadingScreen.showError("Test message")
	
	for relayServer in NorayNetworkConnector.NORAY_SERVERS:
		noray_relay_list.add_item(relayServer)
	noray_relay_list.add_item("Custom")
	noray_relay_list.select(0)
	updateNorayRelayList()

func setScreen(_screen:int):
	currentScreen = _screen
	main_list.visible = (_screen == SCREEN_MAIN)
	tools_container.visible = (_screen == SCREEN_MAIN)
	controls_panel_container.visible = (_screen == SCREEN_MAIN)
	multiplayer_list.visible = (_screen == SCREEN_MULTIPLAYER)
	lan_list.visible = (_screen == SCREEN_MULT_LAN)
	settings_tab.visible = (_screen == SCREEN_SETTINGS)
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
	
	noray_tunnel_list.visible = (_screen == SCREEN_MULT_NORAY)
	noray_relay_bottom_list.visible = (_screen == SCREEN_MULT_NORAY)

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

func _on_lan_button_pressed() -> void:
	setScreen(SCREEN_MULT_LAN)

func _on_lan_host_button_pressed() -> void:
	var theNickame:String = nickname_edit.text if nickname_edit.text else "Host"
	
	GM.hostLANGame(theNickame, "res://Maps/Prison/prison.tscn", GameMode.Sandbox)
	#GM.hostLANGame(theNickame, "res://Maps/CharacterCreatorRoom/character_creator_room.tscn", GameMode.CharacterCreator)

func _on_lan_join_button_pressed() -> void:
	var theNickame:String = nickname_edit.text if !nickname_edit.text.is_empty() else "Client"
	var theIP:String = lan_ip_edit.text if !lan_ip_edit.text.is_empty() else "127.0.0.1"
	
	GM.joinLANGame(theNickame, theIP, lan_server_password.text)


func _on_settings_button_pressed() -> void:
	setScreen(SCREEN_SETTINGS)

func _on_settings_ui_on_cancel_pressed() -> void:
	_on_back_button_pressed()
func _on_settings_ui_on_save_pressed() -> void:
	_on_back_button_pressed()


func _on_noray_host_button_pressed() -> void:
	var theNickame:String = nickname_edit.text if nickname_edit.text else "Host"
	var theRelayServer:String = noray_relay_server_edit.text if !noray_relay_server_edit.text.is_empty() else Network.NORAY_SERVER
	
	var ipPort := Util.separateIPPort(theRelayServer)
	if(ipPort.size() == 1):
		ipPort.append(Network.NORAY_PORT)
	
	GM.hostNoray(theNickame, "res://Maps/Prison/prison.tscn", GameMode.Sandbox, [], ipPort[0], ipPort[1])

func _on_noray_join_button_pressed() -> void:
	var theNickame:String = nickname_edit.text if !nickname_edit.text.is_empty() else "Client"
	var theRoomID:String = noray_room_edit.text if !noray_room_edit.text.is_empty() else ""
	var theRelayServer:String = noray_relay_server_edit.text if !noray_relay_server_edit.text.is_empty() else Network.NORAY_SERVER
	
	var ipPort := Util.separateIPPort(theRelayServer)
	if(ipPort.size() == 1):
		ipPort.append(Network.NORAY_PORT)
	if(theRoomID.is_empty()):
		return
	
	GM.joinNorayGame(theNickame, theRoomID, ipPort[0], ipPort[1], true, noray_server_password.text)

func _on_noray_tunnel_button_pressed() -> void:
	setScreen(SCREEN_MULT_NORAY)

func updateNorayRelayList():
	var relayIndx:int = noray_relay_list.selected
	if(relayIndx < 0):
		return
	if(relayIndx >= NorayNetworkConnector.NORAY_SERVERS.size()): # Custom
		noray_relay_server_edit.visible = true
	else:
		noray_relay_server_edit.visible = false
		noray_relay_server_edit.text = NorayNetworkConnector.NORAY_SERVERS[relayIndx]

func _on_noray_relay_list_item_selected(_index: int) -> void:
	updateNorayRelayList()

func _on_start_game_ui_on_cancel_pressed() -> void:
	setScreen(SCREEN_MAIN)
func _on_load_game_ui_on_cancel_pressed() -> void:
	setScreen(SCREEN_MAIN)

func _on_new_button_pressed() -> void:
	setScreen(SCREEN_START_GAME)
