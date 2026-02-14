extends PanelContainer

@export var gradient:Gradient

@export var propertyName:String = "Property"

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var left_label: Label = %LeftLabel
@onready var right_label: Label = %RightLabel

var cachedValue:float = 0.0

func _ready() -> void:
	setLeftText(propertyName)
	progress_bar.value = 0.0

func setLeftText(_t:String):
	left_label.text = _t

func setRightText(_t:String):
	right_label.text = _t

var tween:Tween
func setValue(_v:float, _force:bool = false) -> bool:
	_v = clampf(_v, 0.0, 1.0)
	if(cachedValue == _v):
		return false
	cachedValue = _v
	
	if(tween):
		tween.kill()
		tween = null
	
	if(!_force):
		tween = create_tween()
		tween.tween_property(progress_bar, "value", _v, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		progress_bar.value = _v
	
	if(gradient):
		progress_bar.get_theme_stylebox("fill").bg_color = gradient.sample(_v)
	
	return true
