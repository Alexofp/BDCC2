extends Control

const SCREEN_MAIN = 0
const SCREEN_MULTIPLAYER = 1
const SCREEN_MULT_LAN = 2

const BACKSCREENS = {
	SCREEN_MULTIPLAYER: SCREEN_MAIN,
	SCREEN_MULT_LAN: SCREEN_MULTIPLAYER,
}

var currentScreen:int = -1

@onready var main_list: VBoxContainer = %MainList
@onready var multiplayer_list: VBoxContainer = %MultiplayerList
@onready var lan_list: VBoxContainer = %LanList

@onready var nickname_edit: LineEdit = %NicknameEdit
@onready var lan_ip_edit: LineEdit = %LanIPEdit

func _ready() -> void:
	setScreen(SCREEN_MAIN)
	
	#LoadingScreen.showError("Test message")

func setScreen(_screen:int):
	currentScreen = _screen
	main_list.visible = (_screen == SCREEN_MAIN)
	multiplayer_list.visible = (_screen == SCREEN_MULTIPLAYER)
	lan_list.visible = (_screen == SCREEN_MULT_LAN)

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
