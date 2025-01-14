extends PropBasic

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color", name="Pipe 1", value=Color.ORANGE},
		"color1": {type="color", name="Pipe 2", value=Color.ORANGE},
		"color2": {type="color", name="Decals", value=Color.WHITE},
		"color3": {type="color", name="Metal", value=Color("353535")},
	}
	return theSettings
