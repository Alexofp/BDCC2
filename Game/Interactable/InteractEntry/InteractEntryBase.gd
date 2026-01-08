extends RefCounted
class_name InteractEntryBase

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		#Bins.BINS, sit_spawner.saveNetworkData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	#sit_spawner.loadNetworkData(_data.readBins())
	_data.endLoad()
			
func saveData() -> Dictionary:
	return {
		#sit = sit_spawner.saveData(),
	}

func loadData(_data:Dictionary):
	#sit_spawner.loadData(SAVE.loadVar(_data, "sit", {}))
	pass
