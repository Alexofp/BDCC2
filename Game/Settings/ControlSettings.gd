extends SettingsBase
class_name ControlSettings

const REMAP_CONTROLS:Dictionary[String, String] = {
	"move_forward": "Move forward",
	"move_back": "Move back",
	"move_left": "Move left",
	"move_right": "Move right",
	
	"camera_up": "Camera up",
	"camera_down": "Camera down",
	"camera_left": "Camera left",
	"camera_right": "Camera right",
	
	"game_combatmode": "Combat mode",
	"combat_attack": "Attack",
	
	"game_interact_menu": "Open interact menu",
	"game_interact": "Quick-interact",
	"game_interact_next": "Quick-interact next",
	"game_interact_prev": "Quick-interact previous",
	
	"move_jump": "Jump",
	"move_sprint": "Run",
	
	"camera_zoomin": "Camera zoom in",
	"camera_zoomout": "Camera zoom out",
	
	"game_charactercreator": "Open character creator",
	
	"game_chat": "Chat",
	
	"debug_noclip": "Noclip",
	"debug_item_giver": "Debug item giver",
	"game_freecam": "Free cam",
	"ui_hide": "Hide UI",
}

var cameraSensitivity:float = 1.0
var cameraSensitivityGamepad:float = 1.0
var invertY:bool = false
var invertYGamepad:bool = false

var defaultControls:Dictionary[String, Array]

func _init() -> void:
	for actionID in REMAP_CONTROLS:
		defaultControls[actionID] = InputMap.action_get_events(actionID).duplicate(true)

func isInputEventSame(_inputEvent1:InputEvent, _inputEvent2:InputEvent) -> bool:
	if(_inputEvent1 == _inputEvent2):
		return true
	
	if((_inputEvent1 is InputEventKey) && (_inputEvent2 is InputEventKey)):
		if(_inputEvent1.physical_keycode != KEY_NONE):
			if(_inputEvent1.physical_keycode == _inputEvent2.physical_keycode):
				return true
		else:
			if(_inputEvent1.keycode == _inputEvent2.keycode):
				return true
		return false
	if((_inputEvent1 is InputEventMouseButton) && (_inputEvent2 is InputEventMouseButton)):
		if(_inputEvent1.button_index == _inputEvent2.button_index):
			return true
		return false
	if((_inputEvent1 is InputEventJoypadButton) && (_inputEvent2 is InputEventJoypadButton)):
		if(_inputEvent1.button_index == _inputEvent2.button_index):
			return true
		return false
	if((_inputEvent1 is InputEventJoypadMotion) && (_inputEvent2 is InputEventJoypadMotion)):
		if(_inputEvent1.axis == _inputEvent2.axis && abs(_inputEvent1.axis_value - _inputEvent2.axis_value)<0.01):
			return true
		return false
	
	return false

func isInputActionSameAsDefault(_actionID:String) -> bool:
	if(!defaultControls.has(_actionID)):
		return false
	var theActions := InputMap.action_get_events(_actionID)
	var theDefaultActions:Array[InputEvent] = defaultControls[_actionID]
	
	if(theActions.size() != theDefaultActions.size()):
		return false
	for _i in theActions.size():
		if(!isInputEventSame(theActions[_i], theDefaultActions[_i])):
			return false
	
	return true

func saveInputEvent(_event:InputEvent) -> Dictionary:
	if(_event is InputEventKey):
		return {
			type = 0,
			key = _event.physical_keycode if _event.physical_keycode != KEY_NONE else _event.keycode,
		}
	if(_event is InputEventMouseButton):
		return {
			type = 1,
			button = _event.button_index,
		}
	if(_event is InputEventJoypadButton):
		return {
			type = 2,
			button = _event.button_index,
		}
	if(_event is InputEventJoypadMotion):
		return {
			type = 3,
			axis = _event.axis,
			value = _event.axis_value,
		}
	
	return {}

func loadInputEvent(_data:Dictionary) -> InputEvent:
	if(!_data.has("type")):
		return null
	var theType:int = SAVE.loadVar(_data, "type", 0)
	if(theType == 0):
		var theEvent := InputEventKey.new()
		theEvent.physical_keycode = SAVE.loadVar(_data, "key", 0)
		return theEvent
	if(theType == 1):
		var theEvent := InputEventMouseButton.new()
		theEvent.button_index = SAVE.loadVar(_data, "button", 0)
		return theEvent
	if(theType == 2):
		var theEvent := InputEventJoypadButton.new()
		theEvent.button_index = SAVE.loadVar(_data, "button", 0)
		return theEvent
	if(theType == 3):
		var theEvent := InputEventJoypadMotion.new()
		theEvent.axis = SAVE.loadVar(_data, "axis", 0)
		theEvent.axis_value = signf(SAVE.loadVar(_data, "value", 1.0))
		return theEvent
	return null

func resetControlsToDefault():
	for inputID in REMAP_CONTROLS:
		InputMap.action_erase_events(inputID)
		for defaultInput in defaultControls[inputID]:
			InputMap.action_add_event(inputID, defaultInput)

func saveData() -> Dictionary:
	var result := super.saveData()
	
	var controlsData:Dictionary[String, Array]
	for inputID in REMAP_CONTROLS:
		if(isInputActionSameAsDefault(inputID)):
			continue
		var theInputs:Array = []
		for theInput in InputMap.action_get_events(inputID):
			var theData:Dictionary = saveInputEvent(theInput)
			if(theData.is_empty()):
				continue
			theInputs.append(theData)
		controlsData[inputID] = theInputs
	
	result["controls"] = controlsData
	
	return result

func loadData(_data:Dictionary):
	super.loadData(_data)
	
	resetControlsToDefault()
	
	var controlsData:Dictionary = SAVE.loadVar(_data, "controls", {})
	for inputID in controlsData:
		if(!REMAP_CONTROLS.has(inputID)):
			continue
		InputMap.action_erase_events(inputID)
		var theInputs:Array = SAVE.loadVar(controlsData, inputID, [])
		for theInput in theInputs:
			if(!(theInput is Dictionary)):
				continue
			var theEvent:InputEvent = loadInputEvent(theInput)
			if(!theEvent):
				continue
			InputMap.action_add_event(inputID, theEvent)

func getSettings() -> Dictionary:
	return {
		"cameraSensitivity": {
			name = "Mouse Camera Sensitivity",
			type = "slider",
			min = 0.0,
			max = 2.0,
			default = 1.0,
		},
		"cameraSensitivityGamepad": {
			name = "Gamepad Camera Sensitivity",
			type = "slider",
			min = 0.0,
			max = 2.0,
			default = 1.0,
		},
		"invertY": {
			name = "Mouse Invert Y",
			type = "bool",
			default = false,
		},
		"invertYGamepad": {
			name = "Gamepad Invert Y",
			type = "bool",
			default = false,
		},
	}


func applySettingValue(_settingID:String, _newVal:Variant):
	match _settingID:
		"cameraSensitivity":
			pass
		"cameraSensitivityGamepad":
			pass
