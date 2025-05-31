extends RefCounted
class_name VoiceProfile

var sexVoice:String = "Fem1"
var pitch:float = 1.0

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
	
