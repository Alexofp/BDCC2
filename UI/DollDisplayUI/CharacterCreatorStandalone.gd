extends Control

@onready var doll_display_ui: SubViewportContainer = %DollDisplayUI
@onready var character_creator: Control = %CharacterCreator

@export var startWithNewChar:bool = false

var character:BaseCharacter
var preset:CharacterPreset

#signal onConfirm(_char:BaseCharacter, _preset:CharacterPreset)
signal onConfirm(_preset:CharacterPreset)
signal onCancel

func _enter_tree() -> void:
	pass
	
func _exit_tree() -> void:
	pass

func loadPreset(_preset:CharacterPreset):
	preset = _preset
	var newChar:BaseCharacter = BaseCharacter.new()
	newChar.inventory.clear()
	#_preset.applyToCharacter(newChar)
	internal_setCharacter(newChar)
	character_creator.setEditingPreset(_preset)

func internal_setCharacter(_char:BaseCharacter):
	character = _char
	doll_display_ui.setCharacter(_char)
	character_creator.setCharacter(_char)
	character_creator.setCustomDoll(doll_display_ui.getDoll())

func newCharacter():
	var newChar:BaseCharacter = BaseCharacter.new()
	newChar.inventory.clear()
	internal_setCharacter(newChar)
	character_creator.setEditingPreset(null)

func _ready() -> void:
	if(startWithNewChar):
		newCharacter()
	character_creator.setCustomCameraSetup(doll_display_ui.getCameraSetup())

func _on_character_creator_on_confirm_pressed() -> void:
	#onConfirm.emit(character, character_creator.getPreset())
	#onConfirm.emit(character_creator.getPreset())
	pass

func _on_character_creator_on_preset_confirmed(_preset: CharacterPreset) -> void:
	onConfirm.emit(_preset)

func _on_character_creator_on_cancel_pressed() -> void:
	onCancel.emit()
