extends PCEditorToolBase

var settings:Dictionary = {}

func _init():
	id = "3SettingsCopy"
	toolHotkey = KEY_3

func getName() -> String:
	return "Copy Settings"

func onApply(_pc:PlayerEditor):
	var _id:int = getPC().getRaycastPropID()
	if(_id >= 0):
		#getPC().applySettingsToProp(_id, settings)
		_pc.doCommand("ChangeSettings", {id=_id, settings=settings})
		showMessage("Pasted settings", 1.0)
	pass

func onApplyAlt(_pc:PlayerEditor):
	var _id:int = getPC().getRaycastPropID()
	if(_id >= 0):
		var theSettings:Dictionary = getPC().getPropSettingsFullByID(_id).duplicate(true)
		#for settingID in theSettings:
			#settings[settingID] = theSettings[settingID]
		for settingID in settings:
			if(!theSettings.has(settingID)):
				theSettings[settingID] = settings[settingID]
		settings = theSettings
		showMessage("Copied settings", 1.0)

func getSettings() -> Dictionary:
	return settings

func applySetting(_id:String, _value:Variant) -> bool:
	if(settings.has(_id)):
		settings[_id]["value"] = _value
	return false

func process(_delta:float, _pc:PlayerEditor):
	var _node:Node3D = getPC().getRaycastNode()
	var _id:int = getPC().getRaycastPropID()
	#print(_node)
	
	if(_id < 0 || _node == null):
		return
	
	var aabb:=PlayerEditor.calculateSpatialBounds(_node, true)
	drawBoxAABB(aabb, _node.global_transform, Color.YELLOW)

func getText() -> String:
	var resultText:String = ""
	resultText += "Right click - copy settings\n"
	resultText += "Left click - paste settings\n"
	resultText += "R - clear buffer\n"
	if(settings.is_empty()):
		resultText += "Buffer is empty\n"
	else:
		resultText += "Buffer has "+str(settings.size())+" setting"+("s" if settings.size() != 1 else "")+"\n"
	
	return resultText

func onKeyPressed(_physicalCode:int, _event:InputEventKey):
	if(_physicalCode == KEY_R && !_event.ctrl_pressed):# && isShifting):
		settings = {}
		showMessage("Cleared settings buffer", 1.0)
