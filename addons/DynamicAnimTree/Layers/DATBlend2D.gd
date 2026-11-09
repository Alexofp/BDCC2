extends DATLayer
class_name DATBlend2D

# No need to have 1D version since you can just use the 2D one to emulate that

class BlendPoint:
	var index:int
	var point:Vector2
	var defaultAnim:String
	var defaultSpeed:float = 1.0
	var defaultBackwards:bool = false

var points:Dictionary[int, BlendPoint]

var smoothEnabled:bool = true
var smoothSpeed:float = 4.0

func addPoint(_index:int, _point:Vector2, _defaultAnim:String = "", _defSpeed:float = 1.0, _defBack:bool = false):
	var newPoint:BlendPoint = BlendPoint.new()
	newPoint.index = _index
	newPoint.point = _point
	newPoint.defaultAnim = _defaultAnim
	newPoint.defaultSpeed = _defSpeed
	newPoint.defaultBackwards = _defBack
	points[_index] = newPoint

func createRunLayer() -> DATBlend2DRun:
	var theLayer:DATBlend2DRun = DATBlend2DRun.new()
	theLayer.smoothEnabled = smoothEnabled
	theLayer.smoothSpeed = smoothSpeed
	return theLayer
