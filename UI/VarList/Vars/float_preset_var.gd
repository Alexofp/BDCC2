extends VarUIBase

@onready var spin_box: SpinBox = $HBoxContainer/HFlowContainer/SpinBox
@onready var h_flow_container: HFlowContainer = $HBoxContainer/HFlowContainer
var presetButtons:Array = []

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
	if(_data.has("presets")):
		for but in presetButtons:
			but.queue_free()
		presetButtons.clear()
		for presetNum in _data["presets"]:
			var but:Button = Button.new()
			but.text = str(presetNum)
			but.pressed.connect(_on_spin_box_value_changed.bind(presetNum))
			h_flow_container.add_child(but)
			presetButtons.append(but)

func _on_spin_box_value_changed(value: float) -> void:
	spin_box.value = value
	triggerChange(value)
