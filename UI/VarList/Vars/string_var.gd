extends VarUIBase

@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
@onready var label: Label = $HBoxContainer/Label

func setData(_data:Dictionary):
	if(_data.has("name")):
		label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		line_edit.text = _data["value"]
	if(_data.has("expandLabel")):
		if(_data["expandLabel"]):
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			label.size_flags_horizontal = Control.SIZE_FILL

func _on_line_edit_text_changed(new_text: String) -> void:
	triggerChange(new_text)

func getValue():
	return line_edit.text
