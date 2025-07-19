@tool
extends PropBasic

@export var roughness:float = 0.5:
	set(value):
		roughness = value
		notifySetEditorValue("roughness", value)
@export var colorbase:Color = Color(0.52549, 0.52549, 0.52549, 1):
	set(value):
		colorbase = value
		notifySetEditorValue("colorbase", value)
@export var color1:Color = Color(0.431373, 0.431373, 0.431373, 1):
	set(value):
		color1 = value
		notifySetEditorValue("color1", value)
@export var color2:Color = Color(0.133333, 0.133333, 0.133333, 1):
	set(value):
		color2 = value
		notifySetEditorValue("color2", value)

func getEditorOptionsEasy() -> Dictionary:
	return {
		"roughness": {type="roughness"},
		"colorbase": {type="color"},
		"color1": {type="color"},
		"color2": {type="color"},
	}

#func getEditorOptionsID() -> String:
#	return EDITOR_OPTIONS_ID_SLOPEDWINDOWBIGSIDE
