extends PanelContainer

func _ready() -> void:
	if(OS.is_debug_build()):
		visible = true
	else:
		visible = false

func _on_combat_moves_button_pressed() -> void:
	GlobalRegistry.reloadCombatMoves()

func _on_dialogue_button_pressed() -> void:
	GlobalRegistry.reloadReactionBanks()
