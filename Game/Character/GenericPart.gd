extends RefCounted
class_name GenericPart

var id:String = "error"
var charRef:WeakRef

signal onOptionChanged(optionID, newValue)

func getName() -> String:
	return "FILL ME"

func getEditorName() -> String:
	return getName()

func getOptions() -> Dictionary:
	return {
		
	}

func getOptionsFinal() -> Dictionary:
	return getOptions()

func getOptionValue(_optionID:String) -> Variant:
	return get(_optionID)

func setOptionValue(_optionID:String, _value:Variant):
	applyOption(_optionID, _value)
	onOptionChanged.emit(_optionID, getOptionValue(_optionID))

func applyOption(_optionID:String, _value:Variant):
	set(_optionID, _value)

func getScenePath(_slot:String) -> String:
	return ""

func createScene(_slot:String) -> Node3D:
	var theScenePath := getScenePath(_slot)
	if(theScenePath == ""):
		return null
	var theSceneClass = load(theScenePath)
	if(theSceneClass == null):
		return null
	return theSceneClass.instantiate()

func getSupportedSkinTypes() -> Dictionary:
	return {}

func getSkinType() -> String:
	return ""

func getSkinTypeData() -> SkinTypeData:
	return null

func supportsSkinTypes() -> bool:
	return !getSupportedSkinTypes().is_empty()

func getCharacter() -> BaseCharacter:
	if(charRef == null):
		return null
	return charRef.get_ref()

func setCharacter(theCharacter:BaseCharacter):
	if(theCharacter == null):
		charRef = null
		return
	charRef = weakref(theCharacter)

func saveOptionsData() -> Dictionary:
	var data:Dictionary = {}
	
	var theOptions:Dictionary = getOptionsFinal()
	for optionID in theOptions:
		data[optionID] = getOptionValue(optionID)
	
	return data

func loadOptionsData(_data:Dictionary):
	var theOptions:Dictionary = getOptionsFinal()
	for optionID in theOptions:
		if(!_data.has(optionID)):
			continue
		setOptionValue(optionID, SAVE.loadVar(_data, optionID, getOptionValue(optionID)))

func saveNetworkData() -> Dictionary:
	return {}

func loadNetworkData(_data:Dictionary):
	pass
