extends PropBasic
class_name PropBasicColors

@export var roughness:float = 0.5
@export var colorbase:Color = Color("868686")
@export var color1:Color = Color("353535")
@export var color2:Color = Color("222222")
@export var color3:Color = Color("111111")

func getEditorOptionsEasy() -> Dictionary:
	return PROP_OPTIONS_FULL
