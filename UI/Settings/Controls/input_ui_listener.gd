extends Control
@onready var input_type_selector: OptionButton = %InputTypeSelector
@onready var input_selector: OptionButton = %InputSelector
@onready var input_label: Label = %InputLabel
@onready var button_catcher: ColorRect = %ButtonCatcher
@onready var detect_button: Button = %DetectButton

signal onAccept(_event:InputEvent)
signal onCancel

var inputEvent:InputEvent

const EVENT_KEY = 0
const EVENT_MOUSE_BUTTON = 1
const EVENT_JOYPAD_BUTTON = 2
const EVENT_JOYPAD_AXIS = 3

const EVENT_TYPES = [
	"Keyboard key",
	"Mouse button",
	"Gamepad button",
	"Gamepad axis",
]

const MOUSE_BUTTONS = [
	#MouseButton.MOUSE_BUTTON_NONE,
	MouseButton.MOUSE_BUTTON_LEFT,
	MouseButton.MOUSE_BUTTON_RIGHT,
	MouseButton.MOUSE_BUTTON_MIDDLE,
	MouseButton.MOUSE_BUTTON_WHEEL_UP,
	MouseButton.MOUSE_BUTTON_WHEEL_DOWN,
	MouseButton.MOUSE_BUTTON_WHEEL_LEFT,
	MouseButton.MOUSE_BUTTON_WHEEL_RIGHT,
	MouseButton.MOUSE_BUTTON_XBUTTON1,
	MouseButton.MOUSE_BUTTON_XBUTTON2,
]

const MOUSE_BUTTONS_NAMES = [
	#"None",
	"Left mouse button",
	"Right mouse button",
	"Middle mouse button",
	"Mouse wheel up",
	"Mouse wheel down",
	"Mouse wheel left",
	"Mouse wheel right",
	"Extra mouse button 1",
	"Extra mouse button 2",
]

const GAMEPAD_AXIS = [
	JOY_AXIS_LEFT_X,
	JOY_AXIS_LEFT_Y,
	JOY_AXIS_RIGHT_X,
	JOY_AXIS_RIGHT_Y,
	JOY_AXIS_TRIGGER_LEFT,
	JOY_AXIS_TRIGGER_RIGHT,
]
const GAMEPAD_AXIS_NAMES = [
	"Left Stick Horizontal",
	"Left Stick Vertical",
	"Right Stick Horizontal",
	"Right Stick Vertical",
	"Left Trigger",
	"Right Trigger",
]

func _ready() -> void:
	for theText in EVENT_TYPES:
		input_type_selector.add_item(theText)
	button_catcher.visible = false
	
	updateInputSelector()
	#popup_window.popup_centered()

func setInput(_inputEvent:InputEvent):
	inputEvent = _inputEvent.duplicate(true)
	updateSelectedOptionBasedOnCurrentInputEvent()

func updateInputSelector():
	input_selector.clear()
	input_label.text = ""
	input_selector.visible = false
	input_label.visible = false
	detect_button.disabled = true
	
	if(inputEvent is InputEventKey):
		input_label.visible = true
		detect_button.disabled = false
		
		var theKey:int = inputEvent.physical_keycode
		if(theKey == KEY_NONE):
			theKey = inputEvent.keycode
		var theStrKey:String = OS.get_keycode_string(theKey)
		if(theStrKey.is_empty()):
			theStrKey = "NONE"
		
		input_label.text = "Selected key: "+theStrKey
	elif(inputEvent is InputEventMouseButton):
		input_selector.visible = true
		var curMouseButton:int = inputEvent.button_index
		
		var butAm:int = MOUSE_BUTTONS.size()
		for _i in butAm:
			input_selector.add_item(MOUSE_BUTTONS_NAMES[_i])
			
			if(MOUSE_BUTTONS[_i] == curMouseButton):
				input_selector.select(_i)
	elif(inputEvent is InputEventJoypadButton):
		input_label.visible = true
		detect_button.disabled = false
		var curMouseButton:int = inputEvent.button_index
		
		var theStrKey:String = InputEventHelper.JOY_BUTTON_NAMES.get(curMouseButton, "Unknown_button:"+str(curMouseButton))
		if(curMouseButton == JOY_BUTTON_INVALID):
			theStrKey = "NONE"
		
		input_label.text = "Selected button: "+theStrKey
	elif(inputEvent is InputEventJoypadMotion):
		input_label.visible = true
		detect_button.disabled = false
		var theAxis:int = inputEvent.axis
		var theAxisVal:float = inputEvent.axis_value
		var theAxisValueText:String = "Neutral"
		if(theAxisVal > 0.0):
			theAxisValueText = "+ Positive"
		if(theAxisVal < 0.0):
			theAxisValueText = "- Negative"
		var theAxisName:String = "Unknown gamepad axis"
		if(theAxis >= 0 && theAxis <= GAMEPAD_AXIS_NAMES.size()):
			theAxisName = GAMEPAD_AXIS_NAMES[theAxis]
		if(theAxis == JOY_AXIS_INVALID):
			theAxisName = "Unassigned gamepad axis"
		input_label.text = theAxisName+" ("+theAxisValueText+")"

func updateSelectedOptionBasedOnCurrentInputEvent():
	if(inputEvent is InputEventKey):
		input_type_selector.select(EVENT_KEY)
	elif(inputEvent is InputEventMouseButton):
		input_type_selector.select(EVENT_MOUSE_BUTTON)
	elif(inputEvent is InputEventJoypadButton):
		input_type_selector.select(EVENT_JOYPAD_BUTTON)
	elif(inputEvent is InputEventJoypadMotion):
		input_type_selector.select(EVENT_JOYPAD_AXIS)
	
	updateInputSelector()

func _on_button_catcher_gui_input(_event: InputEvent) -> void:
	if(_event is InputEventKey):
		if(_event.pressed):
			inputEvent = InputEventKey.new()
			inputEvent.physical_keycode = _event.physical_keycode

			updateSelectedOptionBasedOnCurrentInputEvent()
			button_catcher.visible = false
	if(_event is InputEventJoypadButton):
		if(_event.pressed):
			inputEvent = InputEventJoypadButton.new()
			inputEvent.button_index = _event.button_index

			updateSelectedOptionBasedOnCurrentInputEvent()
			button_catcher.visible = false
	if(_event is InputEventJoypadMotion):
		if(abs(_event.axis_value) > 0.7):
			inputEvent = InputEventJoypadMotion.new()
			inputEvent.axis = _event.axis
			inputEvent.axis_value = signf(_event.axis_value)

			updateSelectedOptionBasedOnCurrentInputEvent()
			button_catcher.visible = false

func _on_detect_button_pressed() -> void:
	button_catcher.visible = true
	button_catcher.grab_focus()
	

func _on_input_type_selector_item_selected(_index: int) -> void:
	if(_index == EVENT_KEY):
		inputEvent = InputEventKey.new()
		inputEvent.physical_keycode = KEY_NONE
	elif(_index == EVENT_MOUSE_BUTTON):
		inputEvent = InputEventMouseButton.new()
		inputEvent.button_index = MOUSE_BUTTON_LEFT
	elif(_index == EVENT_JOYPAD_BUTTON):
		inputEvent = InputEventJoypadButton.new()
		inputEvent.button_index = JOY_BUTTON_INVALID
	elif(_index == EVENT_JOYPAD_AXIS):
		inputEvent = InputEventJoypadMotion.new()
		#inputEvent.button_index = JOY_BUTTON_INVALID
	
	updateSelectedOptionBasedOnCurrentInputEvent()

func _on_accept_button_pressed() -> void:
	onAccept.emit(inputEvent)

func _on_cancel_button_pressed() -> void:
	onCancel.emit()

func _on_input_selector_item_selected(_index: int) -> void:
	if(inputEvent is InputEventMouseButton):
		if(_index < 0 || _index >= MOUSE_BUTTONS.size()):
			return
		inputEvent = InputEventMouseButton.new()
		inputEvent.button_index = MOUSE_BUTTONS[_index]
