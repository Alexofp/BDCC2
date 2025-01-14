extends PropBasic

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color", value=Color("868686")},
		"color1": {type="color", value=Color("353535")},
		"color2": {type="color", value=Color("222222")},
		"color3": {type="colorLight", value=Color("00E0FF")},
	}
	return theSettings
