extends HBoxContainer

var currentValue:bool = false
var id:String = ""
@onready var checkbox = $CheckBox
@onready var label = $Label

signal onValueChange(id, newValue)

func setLabel(newLabel:String):
	label.text = newLabel

func setData(_data:Dictionary):
#	if(data.has("minvalue")):
#		spinbox.min_value = data["minvalue"]
#		hslider.min_value = data["minvalue"]
#	if(data.has("maxvalue")):
#		spinbox.max_value = data["maxvalue"]
#		hslider.max_value = data["maxvalue"]
	pass

func getValue():
	return currentValue

func setValue(newValue):
	currentValue = newValue
	
	checkbox.set_pressed_no_signal(newValue)

func _on_check_box_toggled(button_pressed):
	currentValue = button_pressed
	emit_signal("onValueChange", id, currentValue)
