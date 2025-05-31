extends FaceGestureBase

var timerWait:float = 0.0
var timerBlep:float = 0.0

var closeEyes:bool = false
var crossEyed:bool = false

func _init() -> void:
	id = "Orgasm"
	
	priority = 70.0
	blendInTime = 0.2
	blendOutTime = 0.5
	
	timerWait = RNG.randfRange(1.0, 5.0)
	doesProcessVec2 = true

func processTime(_dt:float):
	if(timerBlep > 0.0):
		timerBlep -= _dt
	#elif(timerWait > 0.0 && getExpressionState() == DollExpressionState.SexReceiving):
		#timerWait -= _dt
		#if(timerWait <= 0.0):
			#timerBlep = RNG.randfRange(1.0, 3.0)
			#timerWait = RNG.randfRange(1.0, 5.0)
	
	setEnabled(timerBlep > 0.0)

func onEvent(_eventID:String, _args:Array):
	if(_eventID == "orgasm"):
		timerWait = 0.0
		timerBlep = 1.0
		closeEyes = RNG.chance(20)
		crossEyed = RNG.chance(10)
		blendOutTime = 0.5
		if(crossEyed && !closeEyes):
			timerBlep = 1.0
			blendOutTime = 10.1
	
func processFaceValue(_valID:int, _val:float) -> float:
	if(_valID == FaceValue.EyesClosed):
		if(closeEyes):
			return RNG.randfRange(0.9, 1.0)
		else:
			return RNG.randfRange(0.0, 0.1)
	if(_valID == FaceValue.LookCross):
		if(crossEyed):
			return RNG.randfRange(0.9, 1.0)
	if(_valID == FaceValue.BrowsShy):
		if(crossEyed || closeEyes):
			return RNG.randfRange(0.9, 1.0)
	#if(_valID == FaceValue.MouthBlep):
		#return max(1.0, _val)
	return _val

func processFaceVec2(_valID:int, _val:Vector2) -> Vector2:
	if(_valID == FaceValue.LookDir):
		_val.x = 0.0
		_val.y = 1.0
		return _val
	return _val

#func updateExpressionState(_expression:int):
	#if(_expression == DollExpressionState.SexReceiving):
		#start()
	#else:
		#stop()
