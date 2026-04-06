extends "res://Game/PawnAI/Actions/DoAction.gd"

func _init() -> void:
	id = "DoActionIfCan"

func onInteractEntryFail():
	completeAction()
