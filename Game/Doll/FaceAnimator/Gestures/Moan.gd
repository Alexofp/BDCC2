extends FaceGestureBase

var moanValue:float = 0.0

func _init() -> void:
	id = "Moan"
	priority = 69.0
	doesProcessVec2 = true

func onEvent(_eventID:String, _args:Array):
	if(_eventID == "moan"):
		doMoan(_args[0], _args[1], _args[2])
	if(_eventID == "moanLoudness"):
		doMoanLoudness(_args[0], _args[1], _args[2], _args[3])

func processFaceVec2(_valID:int, _val:Vector2) -> Vector2:
	if(_valID == FaceValue.LookDir):
		_val.y = lerp(_val.y, 1.0, moanValue*0.5)
		return _val
	return _val

func processFaceValue(_valID:int, _val:float) -> float:
	if(_valID == FaceValue.MouthOpen):
		if(moanValue > 0.0):
			return _val * (1.0 - moanValue) + moanValue
		elif(moanValue < 0.0):
			return max(_val * (1.0 + moanValue), abs(moanValue)*0.1)
	if(_valID == FaceValue.BrowsShy):
		if(moanValue > 0.0):
			return max(moanValue, _val)
	return _val

func doMoan(_soundEntry: SexSoundEntry, _voiceHandler:VoiceHandler, moanMult:float = 1.0):
	var globalMoanMult:float = getAnimator().getMoanMultiplier()
	var soundLen:float = _soundEntry.getLength() / _voiceHandler.voiceProfile.getVoicePitch()
	if(_soundEntry.mouth == SexSoundMouth.Opened):
		doTween("moanValue", [
			[1.0*moanMult*globalMoanMult, soundLen*0.2],
			[0.0, soundLen*0.8],
		])
	else:
		soundLen = max(soundLen, 0.8)
		doTween("moanValue", [
			[-1.0*moanMult, soundLen*0.2],
			[-1.0*moanMult, soundLen*0.3],
			[0.0, soundLen*0.5],
		])

func doMoanLoudness(_soundEntry: SexSoundEntry, _loudness: SexSoundLoudness, _voiceHandler:VoiceHandler, moanMult:float = 1.0):
	var globalMoanMult:float = getAnimator().getMoanMultiplier()
	var soundFrameTime:float = _loudness.frameTime / _voiceHandler.voiceProfile.getVoicePitch()
	var tweenVals:Array = []
	for loudness in _loudness.data:
		tweenVals.append([loudness*moanMult*globalMoanMult, soundFrameTime])
	tweenVals.append([0.0, 0.2])
	doTween("moanValue", tweenVals)
