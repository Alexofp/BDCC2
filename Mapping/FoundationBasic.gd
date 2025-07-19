@tool
extends PropBasic

@export var roughness:float = 0.5:
	set(value):
		roughness = value
		notifySetEditorValue("roughness", value)
@export var colorbase:Color = Color("868686"):
	set(value):
		colorbase = value
		notifySetEditorValue("colorbase", value)
@export var color1:Color = Color("353535"):
	set(value):
		color1 = value
		notifySetEditorValue("color1", value)

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color"},
		"color1": {type="color"},
	}
	return theSettings

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_FOUNDATION
