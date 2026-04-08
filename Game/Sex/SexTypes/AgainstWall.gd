extends "res://Game/Sex/SexTypes/OnTheFloor.gd"

func _init() -> void:
	id = SexType.AgainstWall

func start_run():
	#playAnim(AnimScene.SexStart, "start", {dom=ROLE_DOM, sub=ROLE_SUB})
	playAnim(AnimScene.SexStart, "start", {dom=ROLE_DOM, sub=ROLE_SUB})
