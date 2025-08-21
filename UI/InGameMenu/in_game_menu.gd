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

func tryCloseMenu() -> bool:
	visible = false
	return true

func _ready():
	char_creator_button.visible = showCharCreatorButton

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

func _on_sandbox_menu_button_pressed() -> void:
	onSandboxMenuButton.emit()
