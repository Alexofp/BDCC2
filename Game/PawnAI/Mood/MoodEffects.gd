extends RefCounted
class_name MoodEffects

const FriendlyAgreeMod := 0
const SexAgreeMod := 1
const ExhaustionMod := 2
const AffectionShift := 3

var friendlyAgreeMod:float = 1.0
var sexAgreeMod:float = 1.0
var exhaustionMod:float = 1.0
var affectionShift:float = 0.0

func clear():
	friendlyAgreeMod = 1.0
	sexAgreeMod = 1.0
	exhaustionMod = 1.0
	affectionShift = 0.0

func combineWith(_other:MoodEffects):
	friendlyAgreeMod *= _other.friendlyAgreeMod
	sexAgreeMod *= _other.sexAgreeMod
	exhaustionMod *= _other.exhaustionMod
	affectionShift += _other.affectionShift

func getMod(_mod:int) -> float:
	if(_mod == FriendlyAgreeMod):
		return friendlyAgreeMod
	if(_mod == SexAgreeMod):
		return sexAgreeMod
	if(_mod == ExhaustionMod):
		return exhaustionMod
	if(_mod == AffectionShift):
		return affectionShift
	return 0.0

func getBiggestMod(_value1:float, _value2:float) -> float:
	var theDiff1:float = absf(_value1)
	var theDiff2:float = absf(_value2)
	if(theDiff1 > theDiff2):
		return _value1
	return _value2
