extends ConfirmationDialog

@onready var line_edit: LineEdit = %LineEdit

var charNameFilter:bool = false

signal onApply(window, newText)
signal onClose(window)

func setData(_data:Dictionary):
	if(_data.has("name")):
		title = _data["name"]
	if(_data.has("value")):
		line_edit.text = _data["value"]
	if(_data.has("charNameFilter")):
		charNameFilter = _data["charNameFilter"]

func _on_canceled() -> void:
	onClose.emit(self)

func _on_confirmed() -> void:
	if(charNameFilter):
		if(line_edit.text == ""):
			line_edit.text = "New character"
	onApply.emit(self, line_edit.text)

func _on_line_edit_text_changed(new_text: String) -> void:
	if(charNameFilter):
		var sanitizedText:String = Util.sanitizeCharacterName(new_text)
		if(sanitizedText != new_text):
			line_edit.text = sanitizedText
