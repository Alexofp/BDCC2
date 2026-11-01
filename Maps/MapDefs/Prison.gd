extends MapDef

func _init() -> void:
	id = "Prison"
	gamemodes = [GameMode.Sandbox]
	scenePath = "res://Maps/Prison/prison.tscn"

func getName() -> String:
	return "Default prison"
