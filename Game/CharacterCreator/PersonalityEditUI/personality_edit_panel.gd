extends PanelContainer

@onready var personality_edit_ui: VBoxContainer = %PersonalityEditUI

signal onSave(personality:Personality)
signal onCancel

func setPersonality(_pers:Personality):
	personality_edit_ui.setPersonality(_pers)

func setPersonalityCopy(_pers:Personality):
	var newPers := Personality.new()
	newPers.loadData(_pers.saveData().duplicate(true))
	personality_edit_ui.setPersonality(newPers)

func _on_save_button_pressed() -> void:
	onSave.emit(personality_edit_ui.personality)

func _on_cancel_button_pressed() -> void:
	onCancel.emit()
