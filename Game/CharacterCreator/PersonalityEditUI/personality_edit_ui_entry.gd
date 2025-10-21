extends HBoxContainer

@onready var left_label: Label = %LeftLabel
@onready var right_lebel: Label = %RightLebel
@onready var h_slider: HSlider = %HSlider

var statID:String = PersonalityStat.Mean
var value:float = 0.0

signal onValueChange(statID:String, value:float)

func setStatID(_statID:String):
	statID = _statID
	var thePersStat:PersonalityStatBase = GlobalRegistry.getPersonalityStat(statID)
	if(!thePersStat):
		return
	left_label.text = thePersStat.getNameNegative()
	right_lebel.text = thePersStat.getNamePositive()

func setValue(_val:float):
	value = clamp(_val, -1.0, 1.0)
	h_slider.value = value

func getValue() -> float:
	return value

func _on_h_slider_value_changed(_value: float) -> void:
	value = _value
	onValueChange.emit(statID, value)
