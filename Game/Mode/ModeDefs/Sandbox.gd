extends GameModeDef

var population:int = 5
var prisonName:String = "BDCC"
var map:String = "Prison"

func _init() -> void:
	id = GameMode.Sandbox
	scenePath = "res://Game/Mode/Modes/Sandbox/Sandbox.tscn"

func getName() -> String:
	return "Sandbox"

func getSettings() -> Dictionary:
	var allTheMaps:Array = []
	for theMapID:String in GlobalRegistry.mapDefs:
		var theMapDef:MapDef = GlobalRegistry.mapDefs[theMapID]
		if(!theMapDef.getSupportedGameModes().has(id)):
			continue
		allTheMaps.append([
			theMapID, theMapDef.getName(),
		])
	
	return {
		"prisonName": {
			name = "Prison save name",
			type = "string",
			expandLabel = true,
			value = prisonName,
		},
		"map": {
			name = "Prison map",
			type = "selector",
			value = map,
			values = allTheMaps,
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

func getMapID() -> String:
	return "map"
