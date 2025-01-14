extends VarUIBase

@onready var check_box: CheckBox = $HBoxContainer/CheckBox

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		check_box.set_pressed_no_signal(_data["value"])

func _on_check_box_toggled(toggled_on: bool) -> void:
	triggerChange(toggled_on)
