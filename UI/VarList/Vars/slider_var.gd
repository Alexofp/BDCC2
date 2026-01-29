extends VarUIBase
@onready var spin_box: SpinBox = %SpinBox
@onready var h_slider: HSlider = %HSlider
@onready var label: Label = %Label

func setData(_data:Dictionary):
	if(_data.has("name")):
		label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("step")):
		spin_box.step = _data["step"]
		h_slider.step = _data["step"]
	if(_data.has("min")):
		spin_box.min_value = _data["min"]
		h_slider.min_value = _data["min"]
	if(_data.has("max")):
		spin_box.max_value = _data["max"]
		h_slider.max_value = _data["max"]
	if(_data.has("value")):
		spin_box.value = _data["value"]
		h_slider.value = _data["value"]
	if(_data.has("delayUpdate")):
		spin_box.update_on_text_changed = !_data["delayUpdate"]
	if(_data.has("spaceLabel") && _data["spaceLabel"]):
		label.size_flags_horizontal = SIZE_EXPAND_FILL

func _on_spin_box_value_changed(value: float) -> void:
	h_slider.value = value
	triggerChange(value)

func _on_h_slider_value_changed(value: float) -> void:
	spin_box.value = value
	triggerChange(value)

func getValue():
	return spin_box.value
