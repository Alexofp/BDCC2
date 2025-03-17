extends RefCounted
class_name SkinTypeData

var skinType:String = SkinType.HumanSkin
var color:Color = Color.WHITE

func saveNetworkData() -> Dictionary:
	return {
		skinType = skinType,
		color = color,
	}

func loadNetworkData(_data:Dictionary):
	skinType = SAVE.loadVar(_data, "skinType", SkinType.HumanSkin)
	color = SAVE.loadVar(_data, "color", Color.WHITE)

func makeCopy() -> SkinTypeData:
	var newSkinData:SkinTypeData = SkinTypeData.new()
	newSkinData.skinType = skinType
	newSkinData.color = color
	return newSkinData
