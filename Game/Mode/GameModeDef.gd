extends RefCounted
class_name GameModeDef

var id:String = ""
var scenePath:String = ""

func getName() -> String:
	return id

func getSettings() -> Dictionary:
	return {}

# If returns true, UI stuff will be fully updated
func applySetting(_id:String, _value) -> bool:
	set(_id, _value)
	return false

func canPickFromStartMenu() -> bool:
	return true

func getPopulationSize() -> int:
	return 0

func getMapScenePath() -> String:
	return "res://Maps/Prison/prison.tscn"

func isReadyGetReason() -> String:
	return ""
