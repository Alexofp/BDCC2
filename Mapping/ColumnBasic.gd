extends PropBasic

@export var roughness:float = 0.5
@export var colorbase:Color = Color("353535")
@export var color1:Color = Color("868686")
@export var color2:Color = Color("222222")

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color"},
		"color1": {type="color"},
		"color2": {type="color"},
		#"color3": {type="colorLight", value=Color("00E0FF")},
	}
	return theSettings

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_COLUMN
