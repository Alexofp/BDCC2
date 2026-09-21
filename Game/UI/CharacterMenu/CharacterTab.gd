extends VBoxContainer

@onready var status_effects_list_ui: HFlowContainer = %StatusEffectsListUI

signal onCloseRequest

func setCharacter(_char:BaseCharacter):
	if(!_char):
		return
	status_effects_list_ui.setHolder(_char.effectsHolder)

func _on_masturbate_button_pressed() -> void:
	if(GM.pcPawn):
		GM.pcPawn.askDoInteractEntryDo(InteractEntryDo.create("Masturbate"), null)
		onCloseRequest.emit()
