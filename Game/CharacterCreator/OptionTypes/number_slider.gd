extends HBoxContainer

var currentValue = 0.0
var id:String = ""
@onready var hslider = $HSlider
@onready var spinbox = $SpinBox
@onready var label = $Label

signal onValueChange(id, newValue)

func setLabel(newLabel:String):
	label.text = newLabel

func setData(data:Dictionary):
	if(data.has("minvalue")):
		spinbox.min_value = data["minvalue"]
		hslider.min_value = data["minvalue"]
	if(data.has("maxvalue")):
		spinbox.max_value = data["maxvalue"]
		hslider.max_value = data["maxvalue"]
	if(data.has("step")):
		spinbox.step = data["step"]
		hslider.step = data["step"] / 5.0

func getValue():
	return currentValue

func setValue(newValue):
	currentValue = newValue
	
	spinbox.value = newValue
	hslider.value = newValue

func _on_h_slider_value_changed(value):
	setValue(value)
	
	emit_signal("onValueChange", id, value)
	
func _on_spin_box_value_changed(value):
	setValue(value)
	
	emit_signal("onValueChange", id, value)
	
