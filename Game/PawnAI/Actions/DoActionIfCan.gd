extends "res://Game/PawnAI/Actions/DoAction.gd"

func _init() -> void:
	super._init()
	id = "DoActionIfCan"

func onInteractEntryFail():
	completeAction()
