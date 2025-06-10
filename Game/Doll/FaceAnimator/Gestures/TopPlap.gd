extends FaceGestureBase

var plapValue:float = 0.0
var plap2Value:float = 0.0

func _init() -> void:
	id = "TopLap"
	priority = 68.0
	doesProcessVec2 = true

func onEvent(_eventID:String, _args:Array):
	if(_eventID == "plap"):
		doPlap()

func processFaceVec2(_valID:int, _val:Vector2) -> Vector2:
	#if(_valID == FaceValue.LookDir):
		#_val.y = lerp(_val.y, 1.0, moanValue*0.5)
		#return _val
	return _val

func processFaceValue(_valID:int, _val:float) -> float:
	if(_valID == FaceValue.BrowsAngry):
		return max(plapValue, _val)
	if(_valID == FaceValue.BrowsShy):
		return min(1.0-plapValue, _val)
	if(_valID == FaceValue.MouthOpen):
		return max(plap2Value*0.2, _val)
	if(_valID == FaceValue.MouthSnarl):
		return max(plap2Value*0.2, _val)
	return _val

func doPlap():
	doTween("plapValue", [
		[RNG.randfRange(0.2, 0.7), 0.2],
		[0.0, 0.4],
	])
	doTween("plap2Value", [
		[0.0, 0.1],
		[1.0, 0.3],
		[0.0, 0.4],
	])

func processValues(_vals:FaceAnimator, _dt:float):
	if(plapValue <= 0.0 && plap2Value <= 0.0):
		return
	_vals.valBrowsAngry = max(plapValue, _vals.valBrowsAngry)
	_vals.valBrowsShy = min(1.0-plapValue, _vals.valBrowsShy)
	_vals.valMouthOpen = max(plap2Value*0.2, _vals.valMouthOpen)
	_vals.valMouthSnarl = max(plap2Value*0.2, _vals.valMouthSnarl)
