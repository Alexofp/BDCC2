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

func setButVolume(_name:String, _val:float):
	var sounds_index:int = AudioServer.get_bus_index(_name)
	if(sounds_index < 0):
		Log.error("Audio bus '"+_name+"' not found!")
		return
	AudioServer.set_bus_volume_db(sounds_index, linear_to_db(_val))

func applySettingValue(_settingID:String, newVal:Variant):
	match _settingID:
		"masterVolume":
			setButVolume("Master", newVal)
		"soundVolume":
			setButVolume("Sounds", newVal)
		"voiceVolume":
			setButVolume("Voice", newVal)
			setButVolume("VoiceGagged", newVal)
		"ambientVolume":
			setButVolume("Ambient", newVal)
			setButVolume("AmbientSounds", newVal)
