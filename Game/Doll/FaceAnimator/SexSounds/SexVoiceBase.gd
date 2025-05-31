extends RefCounted
class_name SexVoiceBase

var id:String = "error"
var fallbackID:String = ""

var voiceActors:Array[String] = []
var noisesByType:Dictionary = {}
var noisesSpecific:Dictionary = {} # [type][mouth][intensity][speed]

func getName() -> String:
	return ""

func getVoiceActors() -> Array[String]:
	return voiceActors

func addSoundEntry(theEntry:SexSoundEntry):
	addManySoundEntries([theEntry], theEntry.type, theEntry.mouth, theEntry.intensity, theEntry.speed)

func addManySoundEntries(theEntries:Array, theType:int, theMouthState:int, theIntensity:int, theSpeed:int):
	if(!noisesByType.has(theType)):
		noisesByType[theType] = []
	noisesByType[theType].append_array(theEntries)
	
	if(!noisesSpecific.has(theType)):
		noisesSpecific[theType] = {}
	if(!noisesSpecific[theType].has(theMouthState)):
		noisesSpecific[theType][theMouthState] = {}
	if(!noisesSpecific[theType][theMouthState].has(theIntensity)):
		noisesSpecific[theType][theMouthState][theIntensity] = {}
	if(!noisesSpecific[theType][theMouthState][theIntensity].has(theSpeed)):
		noisesSpecific[theType][theMouthState][theIntensity][theSpeed] = []

	noisesSpecific[theType][theMouthState][theIntensity][theSpeed].append_array(theEntries)

func getSounds(theType:int) -> Array:
	return noisesByType[theType] if noisesByType.has(theType) else []

func getSoundsBestFit(theType:int, mouthState:int, moanIntensity:int, moanSpeed:int) -> Array:
	if(checkSoundsExist(theType, mouthState, moanIntensity, moanSpeed)):
		return getSoundsExact(theType, mouthState, moanIntensity, moanSpeed)
	
	# We're okay with getting sounds that are slower or less intense
	for aSpeed in range(moanSpeed, -1, -1):
		for aIntensity in range(moanIntensity, -1, -1):
			for aMouthState in range(mouthState, -1, -1):
				if(checkSoundsExist(theType, aMouthState, aIntensity, aSpeed)):
					return getSoundsExact(theType, aMouthState, aIntensity, aSpeed)
	
	return []

func soundArgsToStr(mouthState:int, moanIntensity:int, moanSpeed:int) -> String:
	return str(mouthState)+"_"+str(moanIntensity)+"_"+str(moanSpeed)

func getSoundsExact(theType:int, mouthState:int, moanIntensity:int, moanSpeed:int) -> Array:
	if(!noisesSpecific.has(theType)):
		return []
	if(!noisesSpecific[theType].has(mouthState)):
		return []
	if(!noisesSpecific[theType][mouthState].has(moanIntensity)):
		return []
	if(!noisesSpecific[theType][mouthState][moanIntensity].has(moanSpeed)):
		return []
	return noisesSpecific[theType][mouthState][moanIntensity][moanSpeed]

func checkSoundsExist(theType:int, mouthState:int, moanIntensity:int, moanSpeed:int) -> bool:
	if(!noisesSpecific.has(theType)):
		return false
	if(!noisesSpecific[theType].has(mouthState)):
		return false
	if(!noisesSpecific[theType][mouthState].has(moanIntensity)):
		return false
	if(!noisesSpecific[theType][mouthState][moanIntensity].has(moanSpeed)):
		return false
	if(noisesSpecific[theType][mouthState][moanIntensity][moanSpeed].is_empty()):
		return false
	return true

func playPreview(pitchshift:float = 1.0):
	if(noisesByType.is_empty()):
		return
	var randomType:int = RNG.pick(noisesByType.keys())
	var theNoises:Array = noisesByType[randomType]
	if(theNoises.is_empty()):
		return
	var randomNoise:SexSoundEntry = RNG.pick(theNoises)
	var theSoundStream:=Audio.playSound(randomNoise.getAudioStream(), 10.0, Audio.BUS_VOICE)
	theSoundStream.pitch_scale = pitchshift
