extends RefCounted
class_name FetishHolder

var charRef:WeakRef

var performing:Dictionary[String, float] = {}
var receiving:Dictionary[String, float] = {}

signal onFetishUpdate(fetishID:String, isPerforming:bool, value:float)
signal onFetishesUpdated
signal onFetishFullUpdate

func setChar(_char:BaseCharacter):
	charRef = weakref(_char) if _char else null

func getChar() -> BaseCharacter:
	return charRef.get_ref() if charRef else null

func setPerforming(_fetishID:String, _val:float):
	if(!GlobalRegistry.getFetish(_fetishID)):
		return
	_val = clamp(_val, -1.0, 1.0)
	performing[_fetishID] = _val
	onFetishUpdate.emit(_fetishID, true, _val)
	onFetishesUpdated.emit()

func setReceiving(_fetishID:String, _val:float):
	if(!GlobalRegistry.getFetish(_fetishID)):
		return
	_val = clamp(_val, -1.0, 1.0)
	receiving[_fetishID] = _val
	onFetishUpdate.emit(_fetishID, false, _val)
	onFetishesUpdated.emit()

func getPerforming(_fetishID:String) -> float:
	if(!performing.has(_fetishID)):
		return 0.0
	return performing[_fetishID]

func getReceiving(_fetishID:String) -> float:
	if(!receiving.has(_fetishID)):
		return 0.0
	return receiving[_fetishID]

func saveNetworkData() -> Bins:
	var Ar:Array = [
		Bins.I8, performing.size(),
		Bins.I8, receiving.size(),
	]
	for fetishID in performing:
		Ar.append_array([Bins.StrShort, fetishID, Bins.Float, performing[fetishID]])
	for fetishID in receiving:
		Ar.append_array([Bins.StrShort, fetishID, Bins.Float, receiving[fetishID]])
	
	return Bins.saveStartEnd(Ar)

func loadNetworkData(data:Bins):
	performing.clear()
	receiving.clear()
	data.loadStart()
	var _perfAm:int = data.readI8()
	var _receivAm:int = data.readI8()
	for _i in range(_perfAm):
		var theFetishID:String = data.readStrShort()
		var theFetishVal:float = data.readFloat()
		performing[theFetishID] = theFetishVal
	for _i in range(_receivAm):
		var theFetishID:String = data.readStrShort()
		var theFetishVal:float = data.readFloat()
		receiving[theFetishID] = theFetishVal
	data.endLoad()
	onFetishFullUpdate.emit()
	onFetishesUpdated.emit()

func saveData() -> Dictionary:
	return {
		performing = performing,
		receiving = receiving,
	}

func loadData(_data:Dictionary):
	performing = SAVE.loadVar(_data, "performing", {})
	receiving = SAVE.loadVar(_data, "receiving", {})
	onFetishFullUpdate.emit()
	onFetishesUpdated.emit()
