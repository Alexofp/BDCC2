extends Control

@onready var graphics: Control = %Graphics

signal onSavePressed
signal onCancelPressed

func _on_save_button_pressed() -> void:
	OPTIONS.saveToFile()
	onSavePressed.emit()

func _on_cancel_button_pressed() -> void:
	OPTIONS.loadFromFile()
	onCancelPressed.emit()

func _on_default_settings_button_pressed() -> void:
	if(graphics.visible):
		OPTIONS.graphics.resetToDefaults()
		graphics.updateSettingsList()
