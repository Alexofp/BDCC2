extends GameModeDef

var population:int = 5

func _init() -> void:
	id = GameMode.Sandbox
	scenePath = "res://Game/Mode/Modes/Sandbox/Sandbox.tscn"

func getName() -> String:
	return "Sandbox"

func getSettings() -> Dictionary:
	return {
		"population": {
			name = "Population size",
			type = "int",
			value = population,
		},
	}

func getPopulationSize() -> int:
	return population
