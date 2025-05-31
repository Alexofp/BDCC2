extends FaceGestureBase

func _init() -> void:
	id = "SexGiving"
	
	priority = 10.0

func onEvent(_eventID:String, _args:Array):
	pass
	
func processFaceValue(_valID:int, _val:float) -> float:
	if(_valID == FaceValue.MouthOpen):
		return max(0.05, _val)
	#if(_valID == FaceValue.MouthPanting):
	#	return max(0.2, _val)
	if(_valID == FaceValue.MouthSnarl):
		return max(getArousal()*0.2, _val)
	return _val

func updateExpressionState(_expression:int):
	if(_expression == DollExpressionState.SexGiving):
		start()
	else:
		stop()
