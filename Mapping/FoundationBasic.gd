@tool
extends PropBasic

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color", value=Color("868686")},
		"color1": {type="color", value=Color("353535")},
	}
	return theSettings
