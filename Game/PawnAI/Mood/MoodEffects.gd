extends RefCounted
class_name MoodEffects

var friendlyAgreeMod:float = 0.0
var sexAgreeMod:float = 0.0

func clear():
	friendlyAgreeMod = 0.0
	sexAgreeMod = 0.0

func combineWith(_other:MoodEffects):
	friendlyAgreeMod = getBiggestMod(friendlyAgreeMod, _other.friendlyAgreeMod)
	sexAgreeMod = getBiggestMod(sexAgreeMod, _other.sexAgreeMod)

func getBiggestMod(_value1:float, _value2:float) -> float:
	var theDiff1:float = absf(_value1)
	var theDiff2:float = absf(_value2)
	if(theDiff1 > theDiff2):
		return _value1
	return _value2
