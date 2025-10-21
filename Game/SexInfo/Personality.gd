extends RefCounted
class_name Personality

var charRef:WeakRef

var stats:Dictionary[String, float] = {}

signal onStatChange(statID:String, value:float)
signal onStatsUpdated
signal onStatsFullUpdate

func _init() -> void:
	initDefaults()

func initDefaults():
	for statID in GlobalRegistry.getPersonalityStats():
		setStat(statID, 0.0)

func setChar(_char:BaseCharacter):
	charRef = weakref(_char) if _char else null

func getChar() -> BaseCharacter:
	return charRef.get_ref() if charRef else null

func setStat(_statID:String, _val:float):
	if(!GlobalRegistry.getPersonalityStat(_statID)):
		return
	_val = clamp(_val, -1.0, 1.0)
	stats[_statID] = _val
	onStatChange.emit(_statID, _val)
	onStatsUpdated.emit()

func getStat(_statID:String) -> float:
	if(!stats.has(_statID)):
		return 0.0
	return stats[_statID]

func clear():
	stats.clear()
	onStatsFullUpdate.emit()
	onStatsUpdated.emit()

func saveNetworkData() -> Bins:
	var Ar:Array = [
		Bins.I8, stats.size(),
	]
	for statID in stats:
		Ar.append_array([Bins.StrShort, statID, Bins.Float, stats[statID]])
	
	return Bins.saveStartEnd(Ar)

func loadNetworkData(data:Bins):
	stats.clear()
	data.loadStart()
	var statAm:int = data.readI8()
	for _i in range(statAm):
		var theStatID:String = data.readStrShort()
		var theStat:float = data.readFloat()
		stats[theStatID] = theStat
	data.endLoad()
	onStatsFullUpdate.emit()
	onStatsUpdated.emit()

func saveData() -> Dictionary:
	return {
		stats = stats,
	}

func loadData(_data:Dictionary):
	stats = SAVE.loadVar(_data, "stats", {})
	onStatsFullUpdate.emit()
	onStatsUpdated.emit()
