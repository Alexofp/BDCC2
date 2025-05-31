extends RefCounted
class_name FaceGestureBase

var id:String = ""

var enabled:bool = true

var blendInTime:float = 0.1
var blendOutTime:float = 0.1
var influence:float = 1.0

var priority:float = 0.0 # Higher = processed last

var doesProcessValue:bool = true
var doesProcessVec2:bool = false

var animatorRef:WeakRef
func getAnimator() -> FaceAnimator:
	if(!animatorRef):
		return null
	return animatorRef.get_ref()

func getCharState() -> CharState:
	var theAnimator:=getAnimator()
	if(!theAnimator):
		return null
	var theCharacter := theAnimator.getCharacter()
	if(!theCharacter):
		return null
	return theCharacter.getCharState()

func getArousal() -> float:
	var theAnimator:=getAnimator()
	if(!theAnimator):
		return 0.0
	var theCharacter := theAnimator.getCharacter()
	if(!theCharacter):
		return 0.0
	return theCharacter.getArousal()

func createTween() -> Tween:
	return getAnimator().create_tween()

func start():
	enabled = true

func stop():
	enabled = false

func setEnabled(_en:bool):
	if(_en && !enabled):
		start()
	elif(!_en && enabled):
		stop()

func isEnabled() -> bool:
	return enabled

func getTargetInfluence() -> float:
	if(enabled):
		return 1.0
	return 0.0

func processInfluence(_dt:float):
	var theTarget:float = getTargetInfluence()
	
	if(influence < theTarget):
		influence += _dt / blendInTime
		if(influence > theTarget):
			influence = theTarget
	elif(influence > theTarget):
		influence -= _dt / blendOutTime
		if(influence < theTarget):
			influence = theTarget
	
func processTimeFinal(_dt:float):
	processInfluence(_dt)
	processTime(_dt)

func processTime(_dt:float):
	pass

func onEvent(_eventID:String, _args:Array):
	pass

func processFaceValue(_valID:int, _val:float) -> float:
	return _val

func processFaceVec2(_valID:int, _val:Vector2) -> Vector2:
	return _val

func getInfluence() -> float:
	return influence

func getPriority() -> float:
	return priority

func getExpressionState() -> int:
	var theAnimator:=getAnimator()
	if(!theAnimator):
		return DollExpressionState.Normal
	return theAnimator.getExpressionState()

func updateExpressionState(_expression:int):
	pass

func doTween(theVar:String, valPairs:Array) -> Tween:
	return getAnimator().doTween(id+"_"+theVar, self, theVar, valPairs)
