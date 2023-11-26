extends PanelContainer

@onready var touch_screen_button = $TouchScreenButton

func _ready():
	touch_screen_button.scale = size * scale

