extends Panel

@onready var text_label: Label = %TextLabel

func setLabel(_text:String):
	text_label.text = _text
