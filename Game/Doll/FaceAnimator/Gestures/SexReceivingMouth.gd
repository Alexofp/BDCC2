extends FaceGestureBase

func _init() -> void:
	id = "SexReceivingMouth"
	
	priority = 11.2
	blendOutTime = 3.0

func onEvent(_eventID:String, _args:Array):
	pass
	
func processFaceValue(_valID:int, _val:float) -> float:
	if(_valID == FaceValue.MouthOpen):
		return max(0.3, _val)
	return _val

func updateExpressionState(_expression:int):
	setEnabled(_expression == DollExpressionState.SexReceiving)
