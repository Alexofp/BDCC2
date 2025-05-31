extends VarUIBase

@onready var change_button: Button = %ChangeButton

var windowScene := preload("res://UI/VarList/Util/string_change_dialog.tscn")

var charNameFilter:bool = false

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		change_button.text = _data["value"]
	if(_data.has("charNameFilter")):
		charNameFilter = _data["charNameFilter"]

func onWindowTextChange(theWindow, theText:String):
	if(charNameFilter):
		theText = Util.sanitizeCharacterName(theText)
	change_button.text = theText
	theWindow.queue_free()
	triggerChange(theText)

func onWindowClose(theWindow):
	theWindow.queue_free()

func _on_change_button_pressed() -> void:
	var window = windowScene.instantiate()
	add_child(window)
	
	window.setData({
		name = $HBoxContainer/Label.text,
		value = change_button.text,
		charNameFilter = charNameFilter,
	})
	window.onApply.connect(onWindowTextChange)
	window.onClose.connect(onWindowClose)
	
	window.popup_centered()
