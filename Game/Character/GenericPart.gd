extends RefCounted
class_name GenericPart

var id:String = "error"
var charRef:WeakRef
var internalHidePart:bool = false # Should the doll not spawn this part

signal onOptionChanged(optionID, newValue)

#const EDITOR_SKIN = "skin"
const EDITOR_PART = "part"
const EDITOR_INTERACT = "interact"

func _init():
	pass

func getName() -> String:
	return "FILL ME"

func getEditorName() -> String:
	return getName()

func getOptions() -> Dictionary:
	return {
		
	}

func getOptionsFinal() -> Dictionary:
	return getOptions()

func getOptionsFinalWithValues() -> Dictionary:
	var theOptions:Dictionary = getOptionsFinal()
	
	for optionID in theOptions:
		theOptions[optionID]["value"] = getOptionValue(optionID)
	
	return theOptions

func getOptionValue(_optionID:String) -> Variant:
	return get(_optionID)

func setOptionValue(_optionID:String, _value:Variant):
	applyOption(_optionID, _value)
	onOptionChanged.emit(_optionID, getOptionValue(_optionID))

func applyOption(_optionID:String, _value:Variant):
	set(_optionID, _value)

func getScenePath(_slot:int) -> String:
	return ""

func createScene(_slot:int) -> Node3D:
	var theScenePath := getScenePath(_slot)
	if(theScenePath == ""):
		return null
	var theSceneClass = load(theScenePath)
	if(theSceneClass == null):
		return null
	return theSceneClass.instantiate()

func getSupportedSkinTypes() -> Dictionary:
	return {}

func getSkinType() -> int:
	return SkinType.None

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

func shouldBeFilteredOut() -> bool:
	return internalHidePart

func saveOptionsNetworkData() -> Bins:
	var theAr:Array = []
	var theOptions:Dictionary = getOptionsFinal()
	for optionID in theOptions:
		theAr.append_array([Bins.Var, getOptionValue(optionID)])
	
	var data := Bins.saveStart(theAr)
	return data.endSave()

func loadOptionsNetworkData(_data:Bins):
	_data.loadStart()
	var theOptions:Dictionary = getOptionsFinal()
	for optionID in theOptions:
		setOptionValue(optionID, _data.readVar())
	_data.endLoad()

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

func saveNetworkData() -> Bins:
	var data:= Bins.saveStart([
		Bins.BINS, saveOptionsNetworkData(),
	])
	return data.endSave()

func loadNetworkData(_data:Bins):
	_data.loadStart()
	loadOptionsNetworkData(_data.readBins())
	_data.endLoad()

func saveData() -> Dictionary:
	var _data:Dictionary = {}
	
	#if(supportsSkinTypes()):
		#_data["skinType"] = skinType
		#
		#if(skinDataOverride):
			#_data["skinDataOverride"] = skinDataOverride.saveNetworkData()
		#else:
			#_data["skinDataOverride"] = null
	
	_data["options"] = saveOptionsData()
	
	return _data

func loadData(_data:Dictionary):
	#if(supportsSkinTypes()):
		#var skinTypeA = SAVE.loadVar(_data, "skinType", SkinType.None)
		#if(skinTypeA is String):
			#skinTypeA = SkinType.stringToType(skinTypeA)
		#skinType = skinTypeA
		#
		#var newSkinDataOverride = SAVE.loadVar(_data, "skinDataOverride", null)
		#if(newSkinDataOverride == null || !(newSkinDataOverride is Dictionary)):
			#skinDataOverride = null
		#else:
			#skinDataOverride = SkinTypeData.new()
			#skinDataOverride.loadNetworkData(newSkinDataOverride)
	
	loadOptionsData(SAVE.loadVar(_data, "options", {}))
