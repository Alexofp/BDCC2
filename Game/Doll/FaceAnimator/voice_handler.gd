extends Node3D
class_name VoiceHandler

var voiceProfile: VoiceProfile = VoiceProfile.new()
var charID:String = ""

signal onSound(soundType, soundEntry)
signal onEvent(eventID, args)

var runningSounds:Array = []
var noiseQueue:Array = []

var autoMoanTimer:float = 0.0

func pushToQueue(_theEntry:VoiceHandlerEntry):
	popQueueFrontWithPriorityLessThan(_theEntry.priority)
	noiseQueue.append(_theEntry)

func popQueueFrontWithPriorityLessThan(_priority:int, _stopSounds:bool=true):
	while(!noiseQueue.is_empty()):
		var front:VoiceHandlerEntry = noiseQueue.front()
		if(front.priority >= _priority):
			return
		if(_stopSounds && front.played):
			stopAllSounds()
		noiseQueue.pop_front()

func getQueueTime() -> float:
	var result:float = 0.0
	for entry in noiseQueue:
		result += max(entry.waitTime, 0.0)
		result += max(entry.postWaitTime, 0.0)
	return result

func getQueueLength() -> int:
	return noiseQueue.size()

func getQueuePriority() -> int:
	if(noiseQueue.is_empty()):
		return -9999
	return noiseQueue.front().priority
	
func processQueue(_dt:float):
	if(noiseQueue.is_empty()):
		return
	var currentEntry:VoiceHandlerEntry = noiseQueue.front()
	if(currentEntry.waitTime > 0.0):
		currentEntry.waitTime -= _dt
		return
	
	if(!currentEntry.played):
		var soundEntry:SexSoundEntry = currentEntry.sound
		var audioStream := Audio.playSound3D(self, soundEntry.getAudioStream(), -1.0, Audio.BUS_VOICE)
		audioStream.pitch_scale = voiceProfile.getVoicePitch()
		runningSounds.append(audioStream)
		audioStream.finished.connect(audioStreamFinished.bind(audioStream))
		onSound.emit(soundEntry.type, soundEntry)
		currentEntry.played = true
		currentEntry.postWaitTime += soundEntry.length / voiceProfile.getVoicePitch()
	
	if(currentEntry.postWaitTime > 0.0):
		currentEntry.postWaitTime -= _dt
		return
	noiseQueue.pop_front()

func _process(_delta: float) -> void:
	processQueue(_delta)
	
	var theChar:BaseCharacter = getChar()
	if(theChar && theChar.getCharState().shouldAutoMoan()):
		processAutoMoan(_delta)
	#else:
	#	autoMoanTimer = 0.0
	pass

func processAutoMoan(_delta: float) -> void:
	autoMoanTimer -= _delta
	
	if(autoMoanTimer <= 0.0):
		autoMoanTimer = RNG.randfRange(2.0, 3.0)
		
		doMoan(SexSoundSpeed.Slow, SexSoundMouth.Closed, 0)

func _ready() -> void:
	#setVoice("Fem1")
	autoMoanTimer = RNG.randfRange(0.0, 0.5)
	pass

func setVoiceProfile(theVoiceProfile:VoiceProfile):
	voiceProfile.loadData(theVoiceProfile.saveData().duplicate(true))

func setCharID(theCharID:String):
	charID = theCharID

func getChar() -> BaseCharacter:
	return GM.characterRegistry.getCharacter(charID)

func getSoundIntensity() -> int:
	var theChar:BaseCharacter = getChar()
	if(!theChar):
		return SexSoundIntensity.Low
	var arousal:float = theChar.getArousal()
	
	if(arousal <= 0.33):
		return SexSoundIntensity.Low
	if(arousal <= 0.66):
		return SexSoundIntensity.Medium
	return SexSoundIntensity.High

var ignoreNoises:int = 0

var queuedNoise:SexSoundEntry = null
var noiseDelay:float = 0.0
func doMoan(moanSpeed:int = SexSoundSpeed.Slow, mouthState:int = SexSoundMouth.Opened, howManyNextNoisesToIgnore:int=0, overrideIntensity:int = -1):
	if(howManyNextNoisesToIgnore < ignoreNoises):
		ignoreNoises -= 1
	if(ignoreNoises > 0):
		ignoreNoises -= 1
		return
	ignoreNoises = howManyNextNoisesToIgnore
	
	var voice := voiceProfile.getSexVoice()
	var theIntensity:int = getSoundIntensity() if overrideIntensity < 0 else overrideIntensity
	#print(theIntensity)
	var theSounds := voice.getSoundsBestFit(SexSoundType.Moan, mouthState, theIntensity, moanSpeed)
	if(theSounds.is_empty()):
		return
	var randomSound:SexSoundEntry = pickOneOfSexNoises(theSounds)
	
	var queueTime:float = getQueueTime()
	var queueLen:int = getQueueLength()
	if(queueLen >= 2 || queueTime >= 1.0):
		return
	
	var waitTime:float = 0.0
	#var moanSpeed:int = randomSound.speed
	if(moanSpeed == SexSoundSpeed.Slow):
		waitTime = RNG.randfRange(0.0, 0.2)
	elif(moanSpeed == SexSoundSpeed.Medium):
		waitTime = RNG.randfRange(0.0, 0.1)
	pushToQueue(VoiceHandlerEntry.createNoise(
		waitTime, randomSound, 0.0, 0
	))

func sendEvent(_eventID:String, _args:Array):
	onEvent.emit(_eventID, _args)

var lastPlayedNoise:SexSoundEntry
func pickOneOfSexNoises(noises:Array) -> SexSoundEntry:
	var tryCount:int = 3
	while(tryCount > 0):
		var aNoise:SexSoundEntry = RNG.pick(noises)
		if(aNoise != lastPlayedNoise):
			if(lastPlayedNoise && lastPlayedNoise.speed != aNoise.speed):
				noiseDelay *= 0.5
			lastPlayedNoise = aNoise
			return aNoise
		tryCount -= 1
	var result:SexSoundEntry= RNG.pick(noises)
	
	if(lastPlayedNoise && lastPlayedNoise.speed != result.speed):
		noiseDelay *= 0.8
	
	lastPlayedNoise = result
	return result

#var noMoans:bool = false
#func playSexNoise(soundEntry:SexSoundEntry):
	#if(busy):
		#return
	#busy = true
	#var soundLen:float = soundEntry.getLength() / voiceProfile.getVoicePitch()
	#var postSoundWait:float = soundLen #0.1s
	#noiseDelay *= 0.9
	#if(noiseDelay > postSoundWait):
		#postSoundWait = noiseDelay
	#elif(soundLen > noiseDelay):
		#noiseDelay = soundLen
	#
	#if(soundEntry.type == SexSoundType.Moan):
		#if(postSoundWait > soundLen):
			#await get_tree().create_timer(postSoundWait-soundLen).timeout
		#var moanSpeed:int = soundEntry.speed
		#if(moanSpeed == SexSoundSpeed.Slow):
			#await get_tree().create_timer(RNG.randfRange(0.0, 0.2)).timeout
		#elif(moanSpeed == SexSoundSpeed.Medium):
			#await get_tree().create_timer(RNG.randfRange(0.0, 0.1)).timeout
	#
	#var doPlayNoise:bool = true
	#if(soundEntry.type == SexSoundType.Moan && noMoans):
		#doPlayNoise = false
		#
	#if(doPlayNoise):
		#var audioStream := Audio.playSound3D(self, soundEntry.getAudioStream(), -1.0, Audio.BUS_VOICE)
		#audioStream.pitch_scale = voiceProfile.getVoicePitch()
		#runningSounds.append(audioStream)
		##audioStream.tree_exited.connect(func(): busy = false)
		#audioStream.finished.connect(audioStreamFinished.bind(audioStream))
		#onSound.emit(soundEntry.type, soundEntry)
		##await get_tree().create_timer(postSoundWait).timeout
	#
	#await get_tree().create_timer(soundLen).timeout
	#busy = false

func audioStreamFinished(_stream):
	runningSounds.erase(_stream)

func stopAllSounds():
	for stream in runningSounds:
		stream.queue_free()
	runningSounds.clear()

func doOrgasm():
	if(getQueuePriority() >= 100):
		return

	var voice := voiceProfile.getSexVoice()
	var theSounds := voice.getSoundsBestFit(SexSoundType.Orgasm, SexSoundMouth.Opened, SexSoundIntensity.Low, SexSoundSpeed.Slow)
	if(theSounds.is_empty()):
		return
	var theSound := pickOneOfSexNoises(theSounds)
	
	pushToQueue(VoiceHandlerEntry.createNoise(
		0.0, theSound, 0.0, 100,
	))
	
	var theSoundsPanting := voice.getSoundsBestFit(SexSoundType.OrgasmPanting, SexSoundMouth.Opened, SexSoundIntensity.Low, SexSoundSpeed.Slow)
	if(!theSoundsPanting.is_empty()):
		var theSoundPanting := pickOneOfSexNoises(theSoundsPanting)
		#print(theSoundPanting.path)
		pushToQueue(VoiceHandlerEntry.createNoise(
			0.0, theSoundPanting, 0.3, 0,
		))
	
