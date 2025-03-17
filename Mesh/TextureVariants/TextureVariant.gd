extends RefCounted
class_name TextureVariant

var id:String = ""

var name:String = ""

var type:String = ""

var pathTexture:String = ""
var pathColormask:String = ""
var pathNormal:String = ""
var pathORM:String = ""

var flags:Dictionary = {}

func getName() -> String:
	return name

func getFlag(flagID:String, defaultValue:Variant = null):
	if(!flags.has(flagID)):
		return defaultValue
	return flags[flagID]

func loadColormask() -> Texture2D:
	if(pathColormask == ""):
		return null
	return load(pathColormask)
