extends VBoxContainer

@onready var status_effects_list_ui: HFlowContainer = %StatusEffectsListUI

func setCharacter(_char:BaseCharacter):
	if(!_char):
		return
	status_effects_list_ui.setHolder(_char.effectsHolder)
