extends SettingsBase
class_name GameSettings

var autosaveEnabled:bool = true
var autosaveEvery:int = 600

func getSettings() -> Dictionary:
	return {
		"autosaveEnabled": {
			name = "Autosave enabled",
			type = "bool",
			default = true,
		},
		"autosaveEvery": {
			name = "Autosave every",
			type = "selector",
			values = [
				[60, "1 minute"],
				[300, "5 minutes"],
				[600, "10 minutes"],
				[1200, "20 minutes"],
				[1800, "30 minutes"],
				[3600, "60 minutes"],
				[7200, "120 minutes"],
			],
			default = 600,
		},
	}


func applySettingValue(_settingID:String, _newVal:Variant):
	#match _settingID:
	#	"masterVolume":
	#		var sounds_index := AudioServer.get_bus_index("Master")
	#		AudioServer.set_bus_volume_db(sounds_index, linear_to_db(newVal))
	pass
