extends RefCounted
class_name MapDef

var id:String = "error"
var gamemodes:Array[String]
var scenePath:String

func getName() -> String:
	return "FILL ME"

func getSupportedGameModes() -> Array[String]:
	return gamemodes

func getScenePath() -> String:
	return scenePath
