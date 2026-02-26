extends SettingsBase
class_name SoundSettings

var masterVolume:float = 0.5
var soundVolume:float = 1.0
var voiceVolume:float = 1.0
var ambientVolume:float = 0.3

func getSettings() -> Dictionary:
	return {
		"masterVolume": {
			name = "Master volume",
			type = "slider",
			min = 0.0,
			max = 1.0,
			default = 0.5,
		},
		"soundVolume": {
			name = "Sounds volume",
			type = "slider",
			min = 0.0,
			max = 1.0,
			default = 1.0,
		},
		"voiceVolume": {
			name = "Voice volume",
			type = "slider",
			min = 0.0,
			max = 1.0,
			default = 1.0,
		},
		"ambientVolume": {
			name = "Ambient volume",
			type = "slider",
			min = 0.0,
			max = 1.0,
			default = 0.3,
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
		"voiceVolume":
			var sounds_index := AudioServer.get_bus_index("Voice")
			AudioServer.set_bus_volume_db(sounds_index, linear_to_db(newVal))
		"ambientVolume":
			var sounds_index := AudioServer.get_bus_index("Ambient")
			AudioServer.set_bus_volume_db(sounds_index, linear_to_db(newVal))
			var sounds_index2 := AudioServer.get_bus_index("AmbientSounds")
			AudioServer.set_bus_volume_db(sounds_index2, linear_to_db(newVal))
