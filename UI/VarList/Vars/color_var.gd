extends VarUIBase

@onready var color_picker_button: ColorPickerButton = $HBoxContainer/ColorPickerButton

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("alpha")):
		color_picker_button.edit_alpha = _data["alpha"]
	if(_data.has("value")):
		color_picker_button.color = _data["value"]

func _on_color_picker_button_color_changed(color: Color) -> void:
	triggerChange(color)
