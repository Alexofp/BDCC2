extends PropBasic

@export var roughness:float = 0.5
@export var colorbase:Color = Color(0.52549, 0.52549, 0.52549, 1)
@export var color1:Color = Color(0.207843, 0.207843, 0.207843, 1)
@export var color2:Color = Color(1, 1, 1, 1)
@export var color3:Color = Color(0, 0.878431, 1, 1)

func getEditorOptionsEasy() -> Dictionary:
	return PROP_OPTIONS_FULL_LIGHT

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_SLOPEDWINDOWBIG
