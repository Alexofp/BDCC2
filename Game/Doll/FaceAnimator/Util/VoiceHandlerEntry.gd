extends RefCounted
class_name VoiceHandlerEntry

enum {
	NOISE,
}

var type:int = NOISE

var waitTime:float = 0.0
var sound:SexSoundEntry
var postWaitTime:float = 0.0
var priority:int = 0

var played:bool = false

static func createNoise(_wait:float, _sound:SexSoundEntry, _postWaitTime:float, _priority:int = 0) -> VoiceHandlerEntry:
	var newEntry:=VoiceHandlerEntry.new()
	newEntry.type = NOISE
	newEntry.waitTime = _wait
	newEntry.sound = _sound
	newEntry.postWaitTime = _postWaitTime
	newEntry.priority = _priority
	return newEntry
