extends RefCounted
class_name GenericPart

var id:String = "error"

signal onOptionChanged(optionID, newValue)

func getName() -> String:
	return "FILL ME"

func getEditorName() -> String:
	return getName()

func getOptions() -> Dictionary:
	return {
		
	}

func getOptionValue(_optionID:String) -> Variant:
	return get(_optionID)

func setOptionValue(_optionID:String, _value:Variant):
	applyOption(_optionID, _value)
	onOptionChanged.emit(_optionID, getOptionValue(_optionID))

func applyOption(_optionID:String, _value:Variant):
	set(_optionID, _value)

func getPackedScene() -> PackedScene:
	return null

func createScene() -> Node3D:
	var theScene := getPackedScene()
	if(theScene == null):
		return null
	return theScene.instantiate()
