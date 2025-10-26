extends RefCounted
class_name FetishSet

var fetishes:Dictionary[String, float] = {}

signal onFetishChange(fetishID:String, value:float)
signal onUpdate
signal onFullUpdate

func setFetish(_fetish:String, _val:float):
	if(!GlobalRegistry.getFetish(_fetish)):
		return
	_val = clamp(_val, -1.0, 1.0)
	fetishes[_fetish] = _val
	onFetishChange.emit(_fetish, _val)
	onUpdate.emit()

func getFetish(_fetish:String) -> float:
	if(!fetishes.has(_fetish)):
		return 0.0
	return fetishes[_fetish]

func clear():
	fetishes.clear()
	onUpdate.emit()
	onFullUpdate.emit()

func saveNetworkData() -> Bins:
	var Ar:Array = [Bins.I8, fetishes.size()]
	for fetishID in fetishes:
		Ar.append_array([Bins.StrShort, fetishID, Bins.Float, fetishes[fetishID]])
	return Bins.saveStartEnd(Ar)

func loadNetworkData(data:Bins):
	fetishes.clear()
	data.loadStart()
	var fetishAm:int = data.readI8()
	for _i in fetishAm:
		var fetishID:String = data.readStrShort()
		var fetishVal:float = data.readFloat()
		fetishes[fetishID] = fetishVal
	data.endLoad()
	onUpdate.emit()
	onFullUpdate.emit()

func saveData() -> Dictionary:
	return {
		fetishes = fetishes,
	}

func loadData(_data:Dictionary):
	fetishes = SAVE.loadVar(_data, "fetishes", {})
