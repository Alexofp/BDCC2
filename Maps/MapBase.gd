extends Node3D
class_name MapBase

var id:String = "" # Must match the MapDef id

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Var, saveData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	loadData(_data.readVar())
	_data.endLoad()

func saveData() -> Dictionary:
	return {}

func loadData(_data:Dictionary):
	pass
