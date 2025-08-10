extends FaceGestureBase

func _init() -> void:
	id = "OpenMouth"
	
	priority = 10.0
	blendInTime = 0.5
	blendOutTime = 0.3

func onEvent(_eventID:String, _args:Array):
	pass
	
func updateExpressionState(_expression:int):
	if(_expression == DollExpressionState.OpenMouth):
		start()
	else:
		stop()

func processValues(_vals:FaceAnimator, _dt:float):
	processInfluence(_dt)
	
	if(influence <= 0.0):
		return
	_vals.valMouthOpen = lerp(_vals.valMouthOpen, max(0.8, _vals.valMouthOpen), influence)
	
