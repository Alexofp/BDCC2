extends FaceGestureBase

var blinkTween:Tween
var blink:float = 0.0
var blinkTimer:float = 0.0

func _init() -> void:
	id = "Blinking"
	
	priority = 5.0
	blinkTimer = RNG.randfRange(5.0, 15.0)

func onEvent(_eventID:String, _args:Array):
	pass
	
func processFaceValue(_valID:int, _val:float) -> float:
	if(_valID == FaceValue.EyesClosed):
		return _val * (1.0 - blink) + blink
	return _val

func processTime(_dt:float):
	blinkTimer -= _dt
	if(blinkTimer <= 0.0):
		blinkTimer = RNG.randfRange(5.0, 15.0)
		doBlink()

func doBlink():
	if(blinkTween):
		blinkTween.kill()
		blinkTween = null
	blinkTween = createTween()
	var blinkSlow:float = 1.0
	if(getExpressionState() == DollExpressionState.SexReceiving):
		blinkSlow = 5.0 - getArousal()*3.0
	blinkTween.tween_property(self, "blink", 1.0, 0.04*blinkSlow)
	blinkTween.tween_interval(0.05*blinkSlow)
	blinkTween.tween_property(self, "blink", 0.0, 0.12*blinkSlow)
