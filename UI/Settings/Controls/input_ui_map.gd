extends Control

const INPUT_UI_LISTENER = preload("res://UI/Settings/Controls/input_ui_listener.tscn")
const INPUT_UI_ENTRY = preload("res://UI/Settings/Controls/input_ui_entry.tscn")
@onready var input_entries_list: VBoxContainer = %InputEntriesList
@onready var search_controls: LineEdit = %SearchControls

func _ready() -> void:
	updateMap()
	#print(InputMap.action_get_events("ui_down")[2])
	#print(InputMap.action_get_events("ui_up")[2])

func updateMap():
	Util.delete_children(input_entries_list)
	
	var filterText:String = search_controls.text.to_lower()
	var hasFilter:bool = !filterText.is_empty()
	
	#for theEventID in InputMap.get_actions():
	for theEventID in ControlSettings.REMAP_CONTROLS:
		var theNameOfControl:String = ControlSettings.REMAP_CONTROLS[theEventID]
		if(hasFilter && !(filterText in theNameOfControl.to_lower())):
			continue
		
		var newEntry := INPUT_UI_ENTRY.instantiate()
		input_entries_list.add_child(newEntry)
		
		
		#newEntry.setActionID(theEventID, theEventID)
		newEntry.setActionID(theEventID, theNameOfControl)
		
		newEntry.onDeleteBind.connect(onDeleteBindPressed.bind(newEntry))
		newEntry.onEditBindPressed.connect(onEditBindPressed.bind(newEntry))
		newEntry.onAddButtonPressed.connect(onAddButtonPressed.bind(newEntry))
		newEntry.onDefaultButtonPressed.connect(onDefaultButtonPressed.bind(newEntry))

func onDefaultButtonPressed(_actionID:String, _newEntry):
	if(!OPTIONS.controls.defaultControls.has(_actionID)):
		return
	InputMap.action_erase_events(_actionID)
	for defaultEvent in OPTIONS.controls.defaultControls[_actionID]:
		InputMap.action_add_event(_actionID, defaultEvent)
	_newEntry.updateBinds()

func onDeleteBindPressed(_actionID:String, _inputEvent:InputEvent, _newEntry):
	InputMap.action_erase_event(_actionID, _inputEvent)
	_newEntry.updateBinds()

func onAddButtonPressed(_actionID:String, _newEntry):
	var newInput:InputEventKey = InputEventKey.new()
	newInput.physical_keycode = KEY_NONE
	
	var newListener = INPUT_UI_LISTENER.instantiate()
	add_child(newListener)
	newListener.setInput(newInput)
	newListener.onCancel.connect(onListenerCancelPressed.bind(newListener))
	newListener.onAccept.connect(onListenerAddFinished.bind(newListener, _actionID, _newEntry))

func onListenerAddFinished(_event:InputEvent, _theListener, _actionID:String, _newEntry):
	InputMap.action_add_event(_actionID, _event)
	_newEntry.updateBinds()
	_theListener.queue_free()

func onEditBindPressed(_actionID:String, _inputEvent:InputEvent, _newEntry):
	var newListener = INPUT_UI_LISTENER.instantiate()
	add_child(newListener)
	newListener.setInput(_inputEvent)
	newListener.onCancel.connect(onListenerCancelPressed.bind(newListener))
	newListener.onAccept.connect(onListenerEditFinished.bind(newListener, _actionID, _inputEvent, _newEntry))

func onListenerCancelPressed(_theListener):
	_theListener.queue_free()

func onListenerEditFinished(_event:InputEvent, _theListener, _actionID:String, _inputEvent:InputEvent, _newEntry):
	#InputMap.action_erase_event(_actionID, _inputEvent)
	#InputMap.action_add_event(_actionID, _event)
	inputMapReplaceEvent(_actionID, _inputEvent, _event)
	_newEntry.updateBinds()
	_theListener.queue_free()

func inputMapReplaceEvent(_actionID:String, _oldEvent:InputEvent, _newEvent:InputEvent):
	if(!_oldEvent && !_newEvent):
		return
	if(!_oldEvent):
		InputMap.action_add_event(_actionID, _newEvent)
		return
	if(!_newEvent):
		InputMap.action_erase_event(_actionID, _oldEvent)
		return
	
	var allEvents := InputMap.action_get_events(_actionID).duplicate()
	var _i:int = allEvents.find(_oldEvent)
	if(_i < 0):
		return
	allEvents.remove_at(_i)
	allEvents.insert(_i, _newEvent)
	
	InputMap.action_erase_events(_actionID)
	for theEvent in allEvents:
		InputMap.action_add_event(_actionID, theEvent)
	
func _on_search_controls_text_changed(_new_text: String) -> void:
	updateMap()

func _on_visibility_changed() -> void:
	if(is_visible_in_tree()):
		updateMap()
