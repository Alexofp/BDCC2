extends HBoxContainer

var currentValue:Color = Color.WHITE
var id:String = ""
@onready var colorPicker = $ColorPickerButton
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
	
	colorPicker.color = newValue

func _on_color_picker_button_color_changed(color):
	setValue(color)
	
	emit_signal("onValueChange", id, color)
