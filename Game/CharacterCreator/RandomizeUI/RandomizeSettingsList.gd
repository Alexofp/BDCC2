extends VBoxContainer

var settings:RandomizeSettingsHolder = RandomizeSettingsHolder.new()
const RANDOMIZE_SETTING_ENTRY = preload("res://Game/CharacterCreator/RandomizeUI/RandomizeSettingEntry.tscn")

func _ready() -> void:
	updateList()

func updateList():
	Util.delete_children(self)
	
	var theSettings := settings.getSettings()
	for theSettingID in theSettings:
		var theSetting:Dictionary = theSettings[theSettingID]
		
		var newEntry:Control = RANDOMIZE_SETTING_ENTRY.instantiate()
		add_child(newEntry)
		newEntry.setEntry(theSettingID, theSetting)
		newEntry.onSettingChange.connect(onSettingChange)

func getSettings() -> RandomizeSettingsHolder:
	return settings

func onSettingChange(_id:String, _value):
	settings.applySetting(_id, _value)
