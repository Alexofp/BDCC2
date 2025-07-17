extends PropBasic

@export var roughness:float = 0.5
@export var colorbase:Color = Color.ORANGE
@export var color1:Color = Color.ORANGE
@export var color2:Color = Color.WHITE
@export var color3:Color = Color("353535")

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color", name="Pipe 1", value=Color.ORANGE},
		"color1": {type="color", name="Pipe 2", value=Color.ORANGE},
		"color2": {type="color", name="Decals", value=Color.WHITE},
		"color3": {type="color", name="Metal", value=Color("353535")},
	}
	return theSettings

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_PIPE
