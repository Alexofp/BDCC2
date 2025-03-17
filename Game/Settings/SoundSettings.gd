extends SettingsBase
class_name SoundSettings

var masterVolume:float = 1.0
var soundVolume:float = 1.0

func getSettings() -> Dictionary:
	return {
		"masterVolume": {
			name = "Master volume",
			type = "slider",
			min = 0.0,
			max = 1.0,
			default = 1.0,
		},
		"soundVolume": {
			name = "Sounds volume",
			type = "slider",
			min = 0.0,
			max = 1.0,
			default = 1.0,
		},
	}


func applySettingValue(_settingID:String, newVal:Variant):
	match _settingID:
		"masterVolume":
			var sounds_index := AudioServer.get_bus_index("Master")
			AudioServer.set_bus_volume_db(sounds_index, linear_to_db(newVal))
		"soundVolume":
			var sounds_index := AudioServer.get_bus_index("Sounds")
			AudioServer.set_bus_volume_db(sounds_index, linear_to_db(newVal))
