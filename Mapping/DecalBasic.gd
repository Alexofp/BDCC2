@tool
extends PropBasic

@export var roughness:float = 0.5:
	set(value):
		roughness = value
		notifySetEditorValue("roughness", value)
@export var colorbase:Color = Color.WHITE:
	set(value):
		colorbase = value
		notifySetEditorValue("colorbase", value)

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color"},
	}
	return theSettings

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_DECAL
