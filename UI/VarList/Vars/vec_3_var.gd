extends VarUIBase

@onready var spin_box: SpinBox = $HBoxContainer/HBoxContainer/SpinBox
@onready var spin_box_2: SpinBox = $HBoxContainer/HBoxContainer/SpinBox2
@onready var spin_box_3: SpinBox = $HBoxContainer/HBoxContainer/SpinBox3
@onready var spinboxes:Array = [spin_box, spin_box_2, spin_box_3]

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("step")):
		for spbox in spinboxes:
			spbox.step = _data["step"]
	if(_data.has("value")):
		spin_box.value = _data["value"].x
		spin_box_2.value = _data["value"].y
		spin_box_3.value = _data["value"].z
	if(_data.has("delayUpdate")):
		for spbox in spinboxes:
			spbox.update_on_text_changed = !_data["delayUpdate"]

func _on_spin_box_value_changed(_value: float) -> void:
	triggerChange(Vector3(spin_box.value, spin_box_2.value, spin_box_3.value))
