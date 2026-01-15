extends PanelContainer

var actionID:String = ""
var bindsUI:Array

const INPUT_UI_BIND = preload("res://UI/Settings/Controls/input_ui_bind.tscn")
@onready var name_label: Label = %NameLabel
@onready var input_bind_list: VBoxContainer = %InputBindList
@onready var default_button: Button = %DefaultButton

#signal onBindsUpdate(actionID:String, binds:Array[InputEvent])
signal onDefaultButtonPressed(actionID:String)
signal onDeleteBind(actionID:String, inputEvent:InputEvent)
signal onEditBindPressed(actionID:String, inputEvent:InputEvent)
signal onAddButtonPressed(actionID:String)

func setActionID(_actionID:String, _actionName:String):
	actionID = _actionID
	name_label.text = _actionName
	
	updateBinds()

func updateBinds():
	Util.delete_children(input_bind_list)
	bindsUI.clear()
	
	default_button.disabled = OPTIONS.controls.isInputActionSameAsDefault(actionID)
	
	if(!InputMap.has_action(actionID)):
		return
	
	var allInputEvents := InputMap.action_get_events(actionID)
	
	for theEvent in allInputEvents:
		#if(theEvent is InputEventKey):
		var newBind := INPUT_UI_BIND.instantiate()
		input_bind_list.add_child(newBind)
			
		newBind.setInput(theEvent)
		bindsUI.append(newBind)
		
		newBind.onDeletePressed.connect(onBindDeletePressed.bind(newBind))
		newBind.onEditPressed.connect(onBindEditPressed.bind(newBind))

func _on_default_button_pressed() -> void:
	onDefaultButtonPressed.emit(actionID)

func onBindDeletePressed(_theBind):
	onDeleteBind.emit(actionID, _theBind.inputEvent)

func onBindEditPressed(_theBind):
	onEditBindPressed.emit(actionID, _theBind.inputEvent)

func _on_add_button_pressed() -> void:
	onAddButtonPressed.emit(actionID)
