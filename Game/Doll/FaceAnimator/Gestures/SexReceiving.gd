extends FaceGestureBase

var shouldOpenMouth:bool = false

func _init() -> void:
	id = "SexReceiving"
	
	priority = 11.0
	blendOutTime = 2.0

func onEvent(_eventID:String, _args:Array):
	pass
	
func processFaceValue(_valID:int, _val:float) -> float:
	if(_valID == FaceValue.MouthPanting):
		return max(1.0, _val)
	#if(_valID == FaceValue.EyesClosed):
	#	return max(0.2, _val)
	if(_valID == FaceValue.EyesSexy):
		return max(1.0, _val)
	return _val

#func updateExpressionState(_expression:int):
	#if(_expression == DollExpressionState.SexReceiving):
		#start()
	#else:
		#stop()

func processTime(_dt:float):
	var theCharState:CharState = getCharState()
	shouldOpenMouth = (getExpressionState() == DollExpressionState.SexReceiving)
	setEnabled(shouldOpenMouth || theCharState.getAutoMoan() > 0.0)
	
