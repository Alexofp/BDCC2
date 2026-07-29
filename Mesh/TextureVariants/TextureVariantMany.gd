extends RefCounted
class_name TextureVariantMany

const PreviewFolder = "res://Mesh/TextureVariants/Previews/"

var idprefix:String = ""
var type:String = ""
var subType:String = "def"
var previewDollPartPath:String = ""

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
		newVar.previewDollPartPath = previewDollPartPath
		
		var thePreviewPath:String = PreviewFolder.path_join(finalID+".png")
		if(ResourceLoader.exists(thePreviewPath)):
			newVar.previewPath = thePreviewPath
		
		newVar.parse(entry, subType)
		result.append(newVar)
	
	return result
