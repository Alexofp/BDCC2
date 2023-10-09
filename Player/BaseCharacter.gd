extends Node
class_name BaseCharacter

var id:String = "error"
var rootBodypart:BaseBodyBodypart

func _init():
	rootBodypart = BaseBodyBodypart.new()

func getID() -> String:
	return id

func getName() -> String:
	return "Error"

func getRootBodypart() -> BaseBodyBodypart:
	return rootBodypart
