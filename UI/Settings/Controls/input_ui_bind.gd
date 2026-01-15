extends HBoxContainer

var inputEvent:InputEvent
@onready var name_label: Label = %NameLabel
@onready var device_icon: TextureRect = %DeviceIcon
const ICON_DPAD = preload("res://UI/Settings/Controls/Icons/DPad.png")
const ICON_KEY = preload("res://UI/Settings/Controls/Icons/Key.png")
const ICON_MOUSE = preload("res://UI/Settings/Controls/Icons/Mouse.png")
const ICON_STICK = preload("res://UI/Settings/Controls/Icons/Stick.png")

signal onDeletePressed
signal onEditPressed

const GAMEPAD_AXIS_NAMES = [
	"Left Stick Horizontal",
	"Left Stick Vertical",
	"Right Stick Horizontal",
	"Right Stick Vertical",
	"Left Trigger",
	"Right Trigger",
]

func setInput(_event:InputEvent):
	inputEvent = _event
	updateEvent()

func updateEvent():
	if(!inputEvent):
		name_label.text = "NO INPUT EVENT ASSIGNED"
		return
	
	if(inputEvent is InputEventKey):
		var theKey:int= inputEvent.physical_keycode
		if(theKey == KEY_NONE):
			theKey = inputEvent.keycode
		name_label.text = OS.get_keycode_string(theKey)
		if(name_label.text.is_empty()):
			name_label.text = "NONE"
		device_icon.texture = ICON_KEY
	elif(inputEvent is InputEventMouseButton):
		var curMouseButton:int = inputEvent.button_index
		var theText:String = "Unknown mouse button"
		if(curMouseButton >= 0 && curMouseButton < InputEventHelper.MOUSE_BUTTONS_FULL.size()):
			theText = InputEventHelper.MOUSE_BUTTONS_FULL[curMouseButton]
		name_label.text = theText
		device_icon.texture = ICON_MOUSE
	elif(inputEvent is InputEventJoypadButton):
		var curMouseButton:int = inputEvent.button_index
		var theText:String = InputEventHelper.JOY_BUTTON_NAMES.get(curMouseButton, "Unknown_button:"+str(curMouseButton))
		if(curMouseButton == JOY_BUTTON_INVALID):
			theText = "Unassigned gamepad button"
		name_label.text = theText
		device_icon.texture = ICON_DPAD
	elif(inputEvent is InputEventJoypadMotion):
		var theAxis:int = inputEvent.axis
		var theAxisVal:float = inputEvent.axis_value
		var theAxisValueText:String = "(Neutral)"
		if(theAxisVal > 0.0):
			theAxisValueText = "+"
		if(theAxisVal < 0.0):
			theAxisValueText = "-"
		var theAxisName:String = "Unknown gamepad axis"
		if(theAxis >= 0 && theAxis <= GAMEPAD_AXIS_NAMES.size()):
			theAxisName = GAMEPAD_AXIS_NAMES[theAxis]
		if(theAxis == JOY_AXIS_INVALID):
			theAxisName = "Unassigned gamepad axis"
		name_label.text = theAxisName+" "+theAxisValueText
		device_icon.texture = ICON_STICK
	else:
		name_label.text = "Unknown bind"
		device_icon.texture = null

func _on_edit_key_button_pressed() -> void:
	onEditPressed.emit()

func _on_delete_key_button_pressed() -> void:
	onDeletePressed.emit()
