extends RefCounted
class_name VoiceProfile

var sexVoice:String = "Fem1"
var pitch:float = 1.0

func generate(_gen:CharacterGenerator):
	var _gender:int = _gen.gender
	var possible:Dictionary[SexVoiceBase, float] = {}
	for theVoiceID in GlobalRegistry.sexVoices:
		var theVoice:SexVoiceBase = GlobalRegistry.sexVoices[theVoiceID]
		if(_gender == Gender.Male):
			if(theVoice.genMasc > 0.0):
				possible[theVoice] = theVoice.genMasc
		elif(_gender == Gender.Female):
			if(theVoice.genFem > 0.0):
				possible[theVoice] = theVoice.genFem
		else:
			if(theVoice.genAndro > 0.0):
				possible[theVoice] = theVoice.genAndro
	
	if(possible.is_empty()):
		possible = {GlobalRegistry.sexVoices["Fem1"]: 1.0}
	
	var thePickedVoice:SexVoiceBase = RNG.pickWeightedDict(possible)
	if(!thePickedVoice):
		return
	sexVoice = thePickedVoice.id
	pitch = RNG.randfRange(thePickedVoice.genPitchMin, thePickedVoice.genPitchMax)

func setSexVoice(theVoice:String):
	sexVoice = theVoice

func setVoicePitch(_newPitch:float):
	pitch = clamp(_newPitch, 0.5, 5.0)

func getVoicePitch() -> float:
	return pitch

func getSexVoiceID() -> String:
	return sexVoice

func getSexVoice() -> SexVoiceBase:
	return GlobalRegistry.getSexVoice(sexVoice)

func playPreview():
	var theVoice := getSexVoice()
	if(theVoice):
		theVoice.playPreview(getVoicePitch())

func saveData() -> Dictionary:
	return {
		sexVoice = sexVoice,
		pitch = pitch,
	}

func loadData(_data:Dictionary):
	sexVoice = SAVE.loadVar(_data, "sexVoice", "Fem1")
	pitch = SAVE.loadVar(_data, "pitch", 1.0)
	
