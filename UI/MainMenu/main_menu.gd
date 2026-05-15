extends Control

const SCREEN_MAIN = 0
const SCREEN_MULTIPLAYER = 1
const SCREEN_MULT_LAN = 2
const SCREEN_MULT_NODETUNNEL = 3
const SCREEN_SETTINGS = 4
const SCREEN_MULT_NORAY = 5

const BACKSCREENS = {
	SCREEN_MULTIPLAYER: SCREEN_MAIN,
	SCREEN_MULT_LAN: SCREEN_MULTIPLAYER,
	SCREEN_MULT_NODETUNNEL: SCREEN_MULTIPLAYER,
	SCREEN_MULT_NORAY: SCREEN_MULTIPLAYER,
}

var currentScreen:int = -1

@onready var main_list: VBoxContainer = %MainList
@onready var multiplayer_list: VBoxContainer = %MultiplayerList
@onready var lan_list: VBoxContainer = %LanList

@onready var nickname_edit: LineEdit = %NicknameEdit
@onready var lan_ip_edit: LineEdit = %LanIPEdit

@onready var node_tunnel_list: VBoxContainer = %NodeTunnelList
@onready var nt_room_edit: LineEdit = %NTRoomEdit

@onready var nt_relay_server_edit: LineEdit = %NTRelayServerEdit
@onready var nt_relay_bottom_list: VBoxContainer = %NTRelayBottomList
@onready var tools_container: PanelContainer = %ToolsContainer
@onready var settings_tab: MarginContainer = %SettingsTab

@onready var noray_tunnel_list: VBoxContainer = %NorayTunnelList
@onready var noray_room_edit: LineEdit = %NorayRoomEdit
@onready var noray_relay_bottom_list: VBoxContainer = %NorayRelayBottomList
@onready var noray_relay_server_edit: LineEdit = %NorayRelayServerEdit
@onready var noray_relay_list: OptionButton = %NorayRelayList
@onready var controls_panel_container: PanelContainer = %ControlsPanelContainer


func _ready() -> void:
	setScreen(SCREEN_MAIN)
	
	nt_relay_server_edit.text = Network.NODETUNNEL_SERVER
	noray_relay_server_edit.text = Network.NORAY_SERVER
	#LoadingScreen.showError("Test message")
	
	for relayServer in Network.NORAY_SERVERS:
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
	
	node_tunnel_list.visible = (_screen == SCREEN_MULT_NODETUNNEL)
	nt_relay_bottom_list.visible = (_screen == SCREEN_MULT_NODETUNNEL)
	
	noray_tunnel_list.visible = (_screen == SCREEN_MULT_NORAY)
	noray_relay_bottom_list.visible = (_screen == SCREEN_MULT_NORAY)

func _on_play_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Game/Sandbox/Sandbox.tscn")
	#get_tree().change_scene_to_file("res://Game/Main.tscn")
	GM.startGame("res://Maps/Prison/prison.tscn", GameMode.Sandbox)

func _on_char_editor_button_pressed() -> void:
	GM.startGame("res://Maps/CharacterCreatorRoom/character_creator_room.tscn", GameMode.CharacterCreator)

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
	
	GM.joinLANGame(theNickame, theIP)


func _on_nt_host_button_pressed() -> void:
	var theNickame:String = nickname_edit.text if nickname_edit.text else "Host"
	var theRelayServer:String = nt_relay_server_edit.text if !nt_relay_server_edit.text.is_empty() else Network.NODETUNNEL_SERVER
	
	var ipPort := Util.separateIPPort(theRelayServer)
	if(ipPort.size() == 1):
		ipPort.append(Network.NODETUNNEL_PORT)
	
	GM.hostNodeTunnelGame(theNickame, "res://Maps/Prison/prison.tscn", GameMode.Sandbox, [], ipPort[0], ipPort[1])

func _on_nt_join_button_pressed() -> void:
	var theNickame:String = nickname_edit.text if !nickname_edit.text.is_empty() else "Client"
	var theRoomID:String = nt_room_edit.text if !nt_room_edit.text.is_empty() else ""
	var theRelayServer:String = nt_relay_server_edit.text if !nt_relay_server_edit.text.is_empty() else Network.NODETUNNEL_SERVER
	
	var ipPort := Util.separateIPPort(theRelayServer)
	if(ipPort.size() == 1):
		ipPort.append(Network.NODETUNNEL_PORT)
	
	GM.joinNodeTunnelGame(theNickame, theRoomID, ipPort[0], ipPort[1])

func _on_node_tunnel_button_pressed() -> void:
	setScreen(SCREEN_MULT_NODETUNNEL)

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
	
	GM.joinNorayGame(theNickame, theRoomID, ipPort[0], ipPort[1])

func _on_noray_tunnel_button_pressed() -> void:
	setScreen(SCREEN_MULT_NORAY)

func updateNorayRelayList():
	var relayIndx:int = noray_relay_list.selected
	if(relayIndx < 0):
		return
	if(relayIndx >= Network.NORAY_SERVERS.size()): # Custom
		noray_relay_server_edit.visible = true
	else:
		noray_relay_server_edit.visible = false
		noray_relay_server_edit.text = Network.NORAY_SERVERS[relayIndx]

func _on_noray_relay_list_item_selected(_index: int) -> void:
	updateNorayRelayList()
