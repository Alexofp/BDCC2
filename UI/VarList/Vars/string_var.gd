extends VarUIBase

@onready var line_edit: LineEdit = $HBoxContainer/LineEdit

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		line_edit.text = _data["value"]

func _on_line_edit_text_changed(new_text: String) -> void:
	triggerChange(new_text)
