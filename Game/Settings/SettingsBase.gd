extends RefCounted
class_name SettingsBase

func getSettings() -> Dictionary:
	return {
	}

func getSettingDefault(_settingID:String) -> Variant:
	var result:Dictionary = getSettings()
	if(result.has(_settingID) && result[_settingID].has("default")):
		return result[_settingID]["default"]
	return null

func getSettingValue(_settingID:String) -> Variant:
	var result = get(_settingID)
	if(result == null):
		return getSettingDefault(_settingID)
	return result

func setSettingValue(_settingID:String, newVal:Variant):
	set(_settingID, newVal)
	applySettingValue(_settingID, newVal)

func applySettingValue(_settingID:String, _newVal:Variant):
	pass

func getSettingsWithValues() -> Dictionary:
	var result:Dictionary = getSettings()
	
	for settingID in result:
		result[settingID]["value"] = getSettingValue(settingID)
	
	return result

func saveData() -> Dictionary:
	var result:Dictionary = {}
	
	for settingID in getSettings():
		if(settingID.begins_with("nosave_")):
			continue
		result[settingID] = getSettingValue(settingID)
	
	return result

func loadData(_data:Dictionary):
	var theSettings:Dictionary = getSettings()
	for settingID in theSettings:
		if(settingID.begins_with("nosave_")):
			continue
		var settingsEntry:Dictionary = theSettings[settingID]
		var defaultValue = settingsEntry["default"] if settingsEntry.has("default") else null
		
		var newValue = loadVar(_data, settingID, defaultValue)
		var currentValue = getSettingValue(settingID)
		
		if(newValue != currentValue && newValue != null):
			setSettingValue(settingID, newValue)
		

func loadVar(_data:Dictionary, keyID:String, defaultValue:Variant):
	if(!_data.has(keyID)):
		return defaultValue
	return _data[keyID]

func applyAllSettings():
	for settingID in getSettings():
		applySettingValue(settingID, getSettingValue(settingID))

func resetToDefaults():
	var theSettings:Dictionary = getSettings()
	for settingID in theSettings:
		var settingsEntry:Dictionary = theSettings[settingID]
		if(settingsEntry.has("default")):
			setSettingValue(settingID, settingsEntry["default"])
		
