extends AcceptDialog

@onready var text_label: Label = %TextLabel

func addText(_text:String):
	if(!text_label.text.is_empty()):
		text_label.text += "\n"
	text_label.text += _text

func _on_canceled() -> void:
	queue_free()

func _on_confirmed() -> void:
	queue_free()
