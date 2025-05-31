extends RefCounted
class_name SexSoundEntry

var path:String = ""
var length:float = -1.0 # Full length of the sound, in seconds
var trimBack:float = 0.0 # How many seconds of it can be considered silent (from the back)

var type:int = SexSoundType.Moan
var mouth:int = SexSoundMouth.Opened
var intensity:int = SexSoundIntensity.Low
var speed:int = SexSoundSpeed.Slow

var cachedLoudness:SexSoundLoudness

func getLength() -> float:
	if(length < 0.0):
		var theSound:AudioStream = load(path)
		if(theSound):
			length = theSound.get_length()
		else:
			length = 0.0
	return length

func getAudioStream() -> AudioStream:
	return load(path)

func getLoudness() -> SexSoundLoudness:
	if(cachedLoudness):
		return cachedLoudness
	var loudFilePath:String = path+".loud"
	if(!FileAccess.file_exists(loudFilePath)):
		return null
	var file := FileAccess.open(loudFilePath, FileAccess.READ)
	var content := file.get_as_text()
	var dataDict:Dictionary = str_to_var(content)
	var newLoudness:SexSoundLoudness = SexSoundLoudness.new()
	newLoudness.frameTime = dataDict["frameTime"]
	newLoudness.data = dataDict["data"]
	cachedLoudness = newLoudness
	return newLoudness
