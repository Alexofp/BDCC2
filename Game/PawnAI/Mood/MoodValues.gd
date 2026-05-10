extends RefCounted
class_name MoodValues

var mood:float = 0.0 # Happy or Sad
var anger:float = 0.0 # Angry or Friendly
var horny:float = 0.0 # Horny or Chaste
var dominance:float = 0.0 # Dominant or Subby

func clear():
	mood = 0.0
	anger = 0.0
	horny = 0.0
	dominance = 0.0

func combineWith(_other:MoodValues, _mult:float = 1.0):
	mood += _other.mood * _mult
	anger += _other.anger * _mult
	horny += _other.horny * _mult
	dominance += _other.dominance * _mult

func getStat(_mod:int) -> float:
	if(_mod == MoodStat.Mood):
		return mood
	if(_mod == MoodStat.Anger):
		return anger
	if(_mod == MoodStat.Horny):
		return horny
	if(_mod == MoodStat.Dominance):
		return dominance
	return 0.0

func setMood(_v:float) -> MoodValues:
	mood = _v
	return self

func setAnger(_v:float) -> MoodValues:
	anger = _v
	return self

func setHorny(_v:float) -> MoodValues:
	horny = _v
	return self

func setDominance(_v:float) -> MoodValues:
	dominance = _v
	return self
