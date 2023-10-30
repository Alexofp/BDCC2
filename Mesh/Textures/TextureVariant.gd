extends RefCounted
class_name TextureVariant

var id = "error"
var textureName:String = "Error"
var textureType:String = TextureType.None
var textureSubType:String = TextureSubType.Generic
var texturePath:String = "res://icon.svg"
var previewTexturePath:String
var hasR:bool = true
var hasG:bool = true
var hasB:bool = true

func getVisibleName() -> String:
	return textureName

func getTexturePath() -> String:
	return texturePath

func getTexture() -> Texture2D:
	return load(getTexturePath())

func getPreviewTexturePath() -> String:
	if(previewTexturePath != ""):
		return previewTexturePath
	return getTexturePath()
