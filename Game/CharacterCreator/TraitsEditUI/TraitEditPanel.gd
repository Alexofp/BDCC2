extends PanelContainer

@onready var trait_edit_ui: VBoxContainer = %TraitEditUI

signal onSave(_traits:TraitHolder)
signal onCancel
#signal onRandomize

var cachedTrait:TraitHolder

func setTraitHolder(_traits:TraitHolder):
	cachedTrait = _traits
	trait_edit_ui.setTraits(_traits)

func _on_save_button_pressed() -> void:
	onSave.emit(trait_edit_ui.holder)

func _on_cancel_button_pressed() -> void:
	onCancel.emit()

func _on_randomize_button_pressed() -> void:
	trait_edit_ui.holder.randomizeTraits()
	#onRandomize.emit()
	trait_edit_ui.updateList()
	#trait_edit_ui.setTraits(cachedTrait)
