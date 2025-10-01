extends RefCounted
class_name SkinTypeData

var color:Color = Color.WHITE

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Var, color,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	color = _data.readVar()
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		color = color,
	}

func loadData(_data:Dictionary):
	color = SAVE.loadVar(_data, "color", Color.WHITE)

func makeCopy() -> SkinTypeData:
	var newSkinData:SkinTypeData = SkinTypeData.new()
	newSkinData.color = color
	return newSkinData
