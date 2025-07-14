extends RefCounted
class_name CharacterPresetPack

var name:String = "New pack"
var creator:String = "Unknown"
var credits:String = "Fill me"
var filename:String = ""

var presets:Array[CharacterPreset] = []

func getEditorName() -> String:
	return name

func getCreator() -> String:
	return creator

func getCredits() -> String:
	return credits

func getPresets() -> Array[CharacterPreset]:
	return presets

func canBeEdited() -> bool:
	return filename.begins_with("user://")
