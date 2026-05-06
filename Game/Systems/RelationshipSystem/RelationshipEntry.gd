extends RefCounted
class_name RelationshipEntry

var char1:String
var char2:String

var affection:float
var lust:float

#var recentEvents:Array[RelationshipRecentEvent]
#func addRecentEvent(_causerID:String, _eventID:int, _badness:float, _timeRemember:float):
	
func decayEntryShouldRemove(_dt:float) -> bool:
	affection = Util.moveValueTo(affection, 0.0, _dt*0.00001)
	lust = Util.moveValueTo(lust, 0.0, _dt*0.00001)
	
	# Should remove check
	if(absf(affection)<0.001 && absf(lust)<0.001):
		return true
	return false
