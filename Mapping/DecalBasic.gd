@tool
extends PropBasic

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color", value=Color.WHITE},
	}
	return theSettings
