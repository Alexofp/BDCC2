extends RefCounted
class_name RelationshipEntry

var char1:String
var char2:String

var affection:float
var lust:float
var powerBalance:float # 1.0 = char1 dominates char2. -1.0 = char2 dominates char1

#var recentEvents:Array[RelationshipRecentEvent]
#func addRecentEvent(_causerID:String, _eventID:int, _badness:float, _timeRemember:float):

func copyFrom(_otherEntry:RelationshipEntry):
	affection = _otherEntry.affection
	lust = _otherEntry.lust
	powerBalance = _otherEntry.powerBalance

func decayEntryShouldRemove(_dt:float) -> bool:
	affection = Util.moveValueTo(affection, 0.0, _dt*0.00001)
	lust = Util.moveValueTo(lust, 0.0, _dt*0.00001)
	powerBalance = Util.moveValueTo(powerBalance, 0.0, _dt*0.00001)
	
	# Should remove check
	if(absf(affection)<0.001 && absf(lust)<0.001 && absf(powerBalance)<0.001):
		return true
	return false

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.StrShort, char1,
		Bins.StrShort, char2,
		Bins.Float, affection,
		Bins.Float, lust,
		Bins.Float, powerBalance,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	char1 = _data.readStrShort()
	char2 = _data.readStrShort()
	affection = _data.readFloat()
	lust = _data.readFloat()
	powerBalance = _data.readFloat()
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		a = affection,
		l = lust,
		p = powerBalance,
		c1 = char1,
		c2 = char2,
	}

func loadData(_data:Dictionary):
	affection = SAVE.loadVar(_data, "a", 0.0)
	lust = SAVE.loadVar(_data, "l", 0.0)
	powerBalance = SAVE.loadVar(_data, "p", 0.0)
	char1 = SAVE.loadVar(_data, "c1", "")
	char2 = SAVE.loadVar(_data, "c2", "")
