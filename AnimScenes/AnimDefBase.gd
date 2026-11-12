extends RefCounted
class_name AnimDefBase

var id:String = "error"
var scenePath:String = ""

var cachedScene:PackedScene
var shouldCache:bool = true

func getScenePath() -> String:
	return scenePath
