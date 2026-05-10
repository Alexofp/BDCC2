extends RefCounted
class_name MoodHandler

var pawn:CharacterPawn

const NEUTRAL_MOOD_NAME := "Fine"

var moods:Array[MoodBase]
var moodNames:Array[String] = []
var moodName:String = NEUTRAL_MOOD_NAME

# These are [-1.0, 1.0]
var temporaryMood:float = 0.0 # Happy or Sad
var temporaryAnger:float = 0.0 # Angry or Friendly
var temporaryHorny:float = 0.0 # Horny or Chaste
var temporaryDominance:float = 0.0 # Dominant or Subby
#var bored:float # Bored or -
#var tired:float # Tired or -

var values:MoodValues = MoodValues.new()
var effects:MoodEffects = MoodEffects.new()

func setPawn(_p:CharacterPawn):
	pawn = _p

# Should get called every 10 seconds or so
func processRare(_dt:float):
	temporaryMood = tickValueDown(temporaryMood)
	temporaryAnger = tickValueDown(temporaryAnger)
	temporaryHorny = tickValueDown(temporaryHorny)
	temporaryDominance = tickValueDown(temporaryDominance)
	
	values.clear()
	values.mood += temporaryMood
	values.anger += temporaryAnger
	values.horny += temporaryHorny
	values.dominance += temporaryDominance
	values.combineWith(pawn.getCharacter().memoryHolder.moodValues)
	
	updateMoods()

func tickValueDown(_v:float) -> float:
	if(absf(_v) < 0.1):
		return 0.0
	return _v * GM.GB.moodDecayRate

func calcMoodNames() -> Array[String]:
	var result:Array[String] = []
	for theMood in moods:
		var theScore := theMood.calculateScore(pawn, self)
		var theStage := theMood.getStage(theScore)
		if(theStage):
			result.append(theStage.name+"("+str(Util.roundF(theScore, 2))+")")
	return result

func updateMoods():
	if(!Network.isServer()):
		return
	moods.clear()
	effects.clear()
	for theMood in GlobalRegistry.getMoods():
		var theScore:float = theMood.calculateScore(pawn, self)
		if(theScore <= 0.0):
			continue
		moods.append(theMood)
		var theEffects := theMood.getEffects(theScore)
		if(theEffects):
			effects.combineWith(theEffects)
	
	moodNames = calcMoodNames()
	moodName = NEUTRAL_MOOD_NAME if moodNames.is_empty() else Util.humanReadableList(moodNames)

func addMoodRaw(_v:float):
	temporaryMood += _v
func addAngerRaw(_v:float):
	temporaryAnger += _v
func addHornyRaw(_v:float):
	temporaryHorny += _v
func addDomRaw(_v:float):
	temporaryDominance += _v
func addStatRaw(_stat:int, _v:float):
	if(_stat == MoodStat.Mood):
		temporaryMood += _v
	elif(_stat == MoodStat.Anger):
		temporaryAnger += _v
	elif(_stat == MoodStat.Horny):
		temporaryDominance += _v
	elif(_stat == MoodStat.Dominance):
		temporaryDominance += _v

func addMood(_v:float):
	addMoodRaw(_v)
	#mood = affectValue(mood, _v, PersonalityStat.Perceptive, 0.5)
func addAnger(_v:float):
	addAngerRaw(_v)
	#anger = affectValue(anger, _v, PersonalityStat.Mean, 0.7)
func addHorny(_v:float):
	addHornyRaw(_v)
	#horny = affectValue(horny, _v, PersonalityStat.Libido, 0.7)
func addDom(_v:float):
	addDomRaw(_v)
	#dominance = affectValue(dominance, _v, PersonalityStat.Dominant, 0.7)
func addStat(_stat:int, _v:float):
	if(_stat == MoodStat.Mood):
		addMood(_v)
	elif(_stat == MoodStat.Anger):
		addAnger(_v)
	elif(_stat == MoodStat.Horny):
		addHorny(_v)
	elif(_stat == MoodStat.Dominance):
		addDom(_v)

func affectValue(_val:float, _addVal:float, _stat:String, _statMod:float) -> float:
	if(_val > 1.0 && _addVal > 0.0):
		_addVal /= _val
	elif(_val < -1.0 && _addVal < 0.0):
		_addVal /= -_val
	
	if(_addVal > 0.0):
		_val += _addVal * (1.0+_statMod*personality(_stat))
	elif(_addVal < 0.0):
		_val += _addVal * (1.0-_statMod*personality(_stat))
	return _val
	
func personality(_p:String) -> float:
	return pawn.getCharacter().personality.getStat(_p)

func getMoodNames() -> Array[String]:
	return moodNames

func getMoodName() -> String:
	return moodName
