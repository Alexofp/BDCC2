extends VBoxContainer

@onready var fetish_label: Label = %FetishLabel
@onready var value_label: Label = %ValueLabel
@onready var fetish_slider: HSlider = %FetishSlider

var fetishID:String = Fetish.SexVaginal
var performing:bool = false
var value:float = 0.0

signal onValueChange(fetishID:String, value:float)

func setFetishID(_fetishID:String, _isPerf:bool):
	fetishID = _fetishID
	performing = _isPerf
	var theFetish:FetishBase = GlobalRegistry.getFetish(fetishID)
	if(!theFetish):
		return
	fetish_label.text = theFetish.getNamePerforming() if performing else theFetish.getNameReceiving()
	updateValueLabel()

func setValue(_val:float):
	value = clamp(_val, -1.0, 1.0)
	fetish_slider.value = value
	updateValueLabel()

func getLabelText() -> String:
	if(value < -(1.0-0.125)):
		return "Hates"
	if(value < -(0.75-0.125)):
		return "Really dislikes"
	if(value < -(0.5-0.125)):
		return "Dislikes"
	if(value < -(0.25-0.125)):
		return "Slightly dislikes"
	if(value < -(0.0-0.125)):
		return "Neutral"
	if(value < -(-0.25-0.125)):
		return "Slightly likes"
	if(value < -(-0.5-0.125)):
		return "Likes"
	if(value < -(-0.75-0.125)):
		return "Really likes"
	return "Loves"

func updateValueLabel():
	value_label.text = getLabelText()
	print(value, " ",value_label.text)
	

func getValue() -> float:
	return value

func _on_fetish_slider_value_changed(_value: float) -> void:
	value = _value
	onValueChange.emit(fetishID, _value)
	updateValueLabel()
