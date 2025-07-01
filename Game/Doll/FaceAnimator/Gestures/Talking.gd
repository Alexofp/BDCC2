extends FaceGestureBase

var talkValue:float = 0.0

func _init() -> void:
	id = "Talking"
	priority = 75.0

func onEvent(_eventID:String, _args:Array):
	if(_eventID == "talk"):
		var howLong:float = _args[0] if _args.size() > 0 else 3.0
		doTween("talkValue", [
			[1.0, 0.3],
			[1.0, max(howLong-0.3, 0.0)],
			[0.0, 0.3],
		])
	
func processValues(_vals:FaceAnimator, _dt:float):
	_vals.valTalking = max(_vals.valTalking, talkValue - max(0.0, _vals.valMouthOpen))
	
