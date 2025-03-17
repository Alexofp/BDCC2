extends Control

signal onCharCreatorButton
signal onExitButton
signal onSandboxMenuButton

@onready var char_creator_button: Button = %CharCreatorButton
@onready var continue_button: Button = %ContinueButton

@export var showCharCreatorButton:bool = false

var settingsScene = preload("res://UI/Settings/in_game_settings.tscn")

func _enter_tree() -> void:
	UIHandler.addUI(self)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func _ready():
	char_creator_button.visible = showCharCreatorButton
	Network.noray_connected.connect(onNorayConnected)

func _on_continue_button_pressed() -> void:
	visible = false

func _on_char_creator_button_pressed() -> void:
	onCharCreatorButton.emit()

func _on_exit_button_pressed() -> void:
	onExitButton.emit()

func _on_settings_button_pressed() -> void:
	visible = false
	var settingsScreen = settingsScene.instantiate()
	get_parent().add_child(settingsScreen)
	settingsScreen.onSavePressed.connect(onSettingsSaveOrCancel.bind(settingsScreen))
	settingsScreen.onCancelPressed.connect(onSettingsSaveOrCancel.bind(settingsScreen))

func onSettingsSaveOrCancel(theSettings:Control):
	theSettings.queue_free()

func _on_visibility_changed() -> void:
	if(visible):
		continue_button.grab_focus()

@onready var nickname_edit: LineEdit = %NicknameEdit
@onready var ip_address_edit: LineEdit = %IPAddressEdit
@onready var no_ray_oid_edit: LineEdit = %NoRayOIDEdit

func _on_host_button_pressed() -> void:
	var nickname:String = nickname_edit.text if nickname_edit.text != "" else "Host"
	Network.startHost(nickname)


func _on_join_button_pressed() -> void:
	var nickname:String = nickname_edit.text if nickname_edit.text != "" else "Client"
	var theip:String = ip_address_edit.text if ip_address_edit.text != "" else "127.0.0.1"
	Network.joinGame(nickname, theip)


func _on_host_noray_button_pressed() -> void:
	var nickname:String = nickname_edit.text if nickname_edit.text != "" else "Host"
	Network.startHostNORAY(nickname)
	
func onNorayConnected():
	Log.Print("OID = "+str(Noray.oid))
	no_ray_oid_edit.text = Noray.oid

func _on_join_noray_button_pressed() -> void:
	var nickname:String = nickname_edit.text if nickname_edit.text != "" else "Client"
	var theoid:String = no_ray_oid_edit.text
	Network.joinGameNORAY(nickname, theoid)


func _on_sandbox_menu_button_pressed() -> void:
	onSandboxMenuButton.emit()
