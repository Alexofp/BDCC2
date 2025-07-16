extends PropBasic

@export var roughness:float = 0.5
@export var colorbase:Color = Color(0.52549, 0.52549, 0.52549, 1)

func getEditorOptionsEasy() -> Dictionary:
	return {
		"roughness": {type="roughness"},
		"colorbase": {type="color"},
	}

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_MIDDLEPIECECUTOUT
