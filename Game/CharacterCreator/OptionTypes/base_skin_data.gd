extends VBoxContainer

var currentValue:BaseSkinData = BaseSkinData.new()
var id:String = ""
@onready var typeSelector = $TypeSelectorHBox
@onready var colorPicker = $Color
#@onready var label = $Label

signal onValueChange(id, newValue)

func _ready():
	typeSelector.setData({
		"values": [
			["skin", "Skin"],
			["fur", "Fur"],
			["scales", "Scales"],
		]
	})

func setLabel(newLabel:String):
	typeSelector.setLabel(newLabel)
	#label.text = newLabel

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
	currentValue = newValue.makeCopy()
	
	typeSelector.setValue(newValue.skinType)
	colorPicker.setValue(newValue.skinColor)

func _on_type_selector_h_box_on_value_change(_id, newValue):
	currentValue.skinType = newValue
	
	emit_signal("onValueChange", id, currentValue.makeCopy())


func _on_color_on_value_change(_id, newValue):
	currentValue.skinColor = newValue
	
	emit_signal("onValueChange", id, currentValue.makeCopy())
	
