extends VBoxContainer

var currentValue:BaseSkinData = BaseSkinData.new()
var id:String = ""
@onready var typeSelector = $TypeSelectorHBox
@onready var colorPicker = $Color
#@onready var label = $Label
@onready var roughness_slider = $RoughnessSlider
@onready var specular_slider = $SpecularSlider
@onready var rim_slider = $RimSlider
@onready var rim_tint_slider = $RimTintSlider

signal onValueChange(id, newValue)

func _ready():
	typeSelector.setData({
		"values": [
			["skin", "Skin"],
			["fur", "Fur"],
			["scales", "Scales"],
		]
	})
	roughness_slider.setLabel("Roughness")
	roughness_slider.setData({
		"minvalue": 0.0,
		"maxvalue": 1.0,
		"step": 0.05,
	})
	specular_slider.setLabel("Specular")
	specular_slider.setData({
		"minvalue": 0.0,
		"maxvalue": 1.0,
		"step": 0.05,
	})
	rim_slider.setLabel("Rim")
	rim_slider.setData({
		"minvalue": 0.0,
		"maxvalue": 1.0,
		"step": 0.01,
	})
	rim_tint_slider.setLabel("Rim tint")
	rim_tint_slider.setData({
		"minvalue": 0.0,
		"maxvalue": 1.0,
		"step": 0.01,
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
	roughness_slider.setValue(newValue.roughness)
	specular_slider.setValue(newValue.specular)
	rim_slider.setValue(newValue.rim)
	rim_tint_slider.setValue(newValue.rimTint)

func _on_type_selector_h_box_on_value_change(_id, newValue):
	currentValue.skinType = newValue
	
	emit_signal("onValueChange", id, currentValue.makeCopy())


func _on_color_on_value_change(_id, newValue):
	currentValue.skinColor = newValue
	
	emit_signal("onValueChange", id, currentValue.makeCopy())
	
func _on_roughness_slider_on_value_change(id, newValue):
	currentValue.roughness = newValue

	emit_signal("onValueChange", id, currentValue.makeCopy())

func _on_specular_slider_on_value_change(id, newValue):
	currentValue.specular = newValue
	
	emit_signal("onValueChange", id, currentValue.makeCopy())

func _on_rim_slider_on_value_change(id, newValue):
	currentValue.rim = newValue
	
	emit_signal("onValueChange", id, currentValue.makeCopy())

func _on_rim_tint_slider_on_value_change(id, newValue):
	currentValue.rimTint = newValue
	
	emit_signal("onValueChange", id, currentValue.makeCopy())
