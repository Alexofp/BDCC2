extends Control
@onready var virtual_joystick = $"Virtual Joystick"
@onready var virtual_joystick_2 = $"Virtual Joystick2"
@onready var control_touch_screen_button = $ControlTouchScreenButton
@onready var control_touch_screen_button_2 = $ControlTouchScreenButton2
@onready var control_touch_screen_button_3 = $ControlTouchScreenButton3

func _ready():
	UiHandler.onAnyUIVisibleChanged.connect(onUIsVisiblityChanged)
	onUIsVisiblityChanged(UiHandler.hasAnyUIVisible())
	
	if(!DisplayServer.is_touchscreen_available()): #  && false
		visible = false

func onUIsVisiblityChanged(newVis):
	virtual_joystick.visible = !newVis
	virtual_joystick_2.visible = !newVis
	control_touch_screen_button.visible = !newVis
	control_touch_screen_button_3.visible = !newVis
