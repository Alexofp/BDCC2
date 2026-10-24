extends GameModeDef

var population:int = 5
var prisonName:String = "BDCC"

func _init() -> void:
	id = GameMode.Sandbox
	scenePath = "res://Game/Mode/Modes/Sandbox/Sandbox.tscn"

func getName() -> String:
	return "Sandbox"

func getSettings() -> Dictionary:
	return {
		"prisonName": {
			name = "Prison save name",
			type = "string",
			value = prisonName,
		},
		"population": {
			name = "Population size",
			type = "int",
			value = population,
		},
	}

func getPopulationSize() -> int:
	return population

func getPrisonName() -> String:
	return prisonName
