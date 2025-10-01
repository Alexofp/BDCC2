extends RigidBody3D

func _ready() -> void:
	pass

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd()

func loadNetworkData(_data:Bins):
	_data.loadStart()
	_data.endLoad()

func saveData() -> Dictionary:
	return {}

func loadData(_data:Dictionary):
	pass
