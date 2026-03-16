extends Button

signal onPressed

func setCategoryName(_str:String):
	text = "["+_str+"]"

func _on_pressed() -> void:
	onPressed.emit()
