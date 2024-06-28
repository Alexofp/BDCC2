extends RefWithOptions
class_name BodypartExtra

var id:String = "error"
var supportedBodypartIDs:Array = []
var attachToSlot:String = ""

var rootRef: WeakRef
var parentPart: WeakRef

func _init():
	super._init()

func getCharacter() -> BaseCharacter:
	if(rootRef == null):
		return null
	return rootRef.get_ref()

func getParentBodypart() -> BaseBodypart:
	if(parentPart == null):
		return null
	return parentPart.get_ref()

func getVisibleName():
	return "Whiskers"

func getMeshPath() -> String:
	return "res://Mesh/Parts/Head/FelineHead/Extras/Whiskers/feline_whiskers.tscn"
