extends FaceGestureBase

var dirTimer:float = 0.0
var eyeDirTween:Tween
var lookDir:Vector2 = Vector2(0.0, 0.0)

func _init() -> void:
	id = "LookDir"
	priority = 3.0
	
	doesProcessValue = false
	doesProcessVec2 = true
	
	dirTimer = RNG.randfRange(1.0, 2.0)
	
func processTime(_dt:float):
	dirTimer -= _dt
	if(dirTimer <= 0.0):
		dirTimer = RNG.randfRange(1.0, 10.0)
		doChangeDir()

func doChangeDir():
	if(eyeDirTween):
		eyeDirTween.kill()
		eyeDirTween = null
	var transTime:float = 0.05
	var maxVal:float = 0.2
	eyeDirTween = createTween()
	eyeDirTween.tween_property(self, "lookDir", Vector2(RNG.randfRange(-maxVal, maxVal), RNG.randfRange(-maxVal, maxVal)), transTime)

func processFaceVec2(_valID:int, _val:Vector2) -> Vector2:
	if(_valID == FaceValue.LookDir):
		return lookDir
	return _val
