extends PropBasic

@export var roughness:float = 0.5
@export var colorbase:Color = Color(0.52549, 0.52549, 0.52549, 1)
@export var color1:Color = Color(0.431373, 0.431373, 0.431373, 1)
@export var color2:Color = Color(0.133333, 0.133333, 0.133333, 1)

func getEditorOptionsEasy() -> Dictionary:
	return {
		"roughness": {type="roughness"},
		"colorbase": {type="color"},
		"color1": {type="color"},
		"color2": {type="color"},
	}

#func getEditorOptionsID() -> String:
#	return EDITOR_OPTIONS_ID_SLOPEDWINDOWBIGSIDE
