@tool
extends PropBasic

@export var roughness:float = 0.5:
	set(value):
		roughness = value
		notifySetEditorValue("roughness", value)
@export var colorbase:Color = Color("8e8e8e"):
	set(value):
		colorbase = value
		notifySetEditorValue("colorbase", value)
@export var color1:Color = Color("868686"):
	set(value):
		color1 = value
		notifySetEditorValue("color1", value)
@export var color2:Color = Color("222222"):
	set(value):
		color2 = value
		notifySetEditorValue("color2", value)
@export var color3:Color = Color("00E0FF"):
	set(value):
		color3 = value
		notifySetEditorValue("color3", value)
@export var tileColor:Color = Color("8e8e8e"):
	set(value):
		tileColor = value
		notifySetEditorValue("tileColor", value)

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color"},
		"color1": {type="color"},
		"color2": {type="color"},
		"color3": {type="colorLight"},
		"tileColor": {type="color"},
	}
	return theSettings

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_MAINHALL
