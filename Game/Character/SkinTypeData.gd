extends RefCounted
class_name SkinTypeData

var color:Color = Color.WHITE

func saveNetworkData() -> Dictionary:
	return {
		color = color,
	}

func loadNetworkData(_data:Dictionary):
	color = SAVE.loadVar(_data, "color", Color.WHITE)

func saveData() -> Dictionary:
	return saveNetworkData()

func loadData(_data:Dictionary):
	loadNetworkData(_data)

func makeCopy() -> SkinTypeData:
	var newSkinData:SkinTypeData = SkinTypeData.new()
	newSkinData.color = color
	return newSkinData
