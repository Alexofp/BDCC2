@tool
extends PanelContainer

@export var gradientPositive:Gradient
@export var gradientNegative:Gradient

@export var stageAmountPositive:int = 3
@export var stageAmountNegative:int = 3

@export var propertyName:String = "Property"

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var left_label: Label = %LeftLabel
@onready var right_label: Label = %RightLabel

@export var value:float = 0.0:
	set(_v):
		setValue(_v, false)
		value = _v
	get:
		return cachedValue
var visualValue:float = 0.0

var styleBackground:StyleBox
var styleFill:StyleBox

var cachedValue:float = 0.0

func _ready() -> void:
	setLeftText(propertyName)
	progress_bar.value = 0.0
	
	styleBackground = progress_bar.get_theme_stylebox("background")
	styleFill = progress_bar.get_theme_stylebox("fill")

func setLeftText(_t:String):
	left_label.text = _t

func setRightText(_t:String):
	right_label.text = _t

var tween:Tween
func setValue(_v:float, _force:bool = false) -> bool:
	#_v = clampf(_v, 0.0, 1.0)
	if(cachedValue == _v):
		return false
	cachedValue = _v
	
	if(tween):
		tween.kill()
		tween = null
	
	if(!_force):
		tween = create_tween()
		tween.tween_method(setVisualValue, visualValue, _v, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		#tween.tween_property(progress_bar, "value", _v, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		setVisualValue(_v)
		#progress_bar.value = _v
	
	#if(gradientPositive):
	#	progress_bar.get_theme_stylebox("fill").bg_color = gradientPositive.sample(_v)
	
	return true

func setVisualValue(_val:float):
	var progressBarValue:float = absf(fmod(_val, 1.0))
	progress_bar.value = progressBarValue
	
	var theStartStage:int = int(_val)
	var theEndStage:int = int(ceilf(_val) if _val > 0.0 else floorf(_val))
	
	styleBackground.bg_color = getColorAtStage(theStartStage)
	styleFill.bg_color = getColorAtStage(theEndStage)
	
	visualValue = _val
	
	#print(_val,"  ",theStartStage, "   ",theEndStage,"   ",progressBarValue)

func getColorAtStage(_stage:int) -> Color:
	if(_stage == 0):
		return Color("#333333")
	if(gradientPositive && _stage > 0 && _stage <= stageAmountPositive):
		var theVal:float = float(_stage) / float(stageAmountPositive)
		return gradientPositive.sample(theVal)
	if(gradientNegative && _stage < 0 && (-_stage) <= stageAmountNegative):
		var theVal:float = float(-_stage) / float(stageAmountNegative)
		return gradientNegative.sample(theVal)
	
	return Color("#111111")

@export_tool_button("Test progress", "Callable") var doTest_action = doTest

func doTest():
	setValue(RNG.randfRange(-3.0, 3.0), false)
	#setVisualValue(RNG.randfRange(-3.0, 3.0))
