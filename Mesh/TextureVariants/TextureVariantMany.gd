extends RefCounted
class_name TextureVariantMany

var idprefix:String = ""
var type:String = ""
var subType:String = "def"

var textures:Dictionary = {
	#"something": {texture="dsa.png", orm="asd.png"},
}

func getVariants() -> Array:
	var result:Array = []
	
	for entryID in textures:
		var entry:Dictionary = textures[entryID]
		var finalID:String = idprefix+entryID
		
		var newVar:TextureVariant = TextureVariant.new()
		newVar.id = finalID
		newVar.type = type
		if(entry.has("name")):
			newVar.name = entry["name"]
		else:
			newVar.name = finalID
		if(entry.has("texture")):
			newVar.pathTexture = entry["texture"]
		if(entry.has("normal")):
			newVar.pathNormal = entry["normal"]
		if(entry.has("colormask")):
			newVar.pathColormask = entry["colormask"]
		if(entry.has("orm")):
			newVar.pathORM = entry["orm"]
		if(entry.has("flags")):
			newVar.flags = entry["flags"]
		result.append(newVar)
	
	return result
