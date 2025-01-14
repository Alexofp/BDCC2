extends VarUIBase
@onready var spin_box: SpinBox = $HBoxContainer/SpinBox

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("step")):
		spin_box.step = _data["step"]
	if(_data.has("value")):
		spin_box.value = _data["value"]
	if(_data.has("delayUpdate")):
		spin_box.update_on_text_changed = !_data["delayUpdate"]

func _on_spin_box_value_changed(value: float) -> void:
	triggerChange(value)
