extends Control
@onready var settings_list: VarList = %SettingsList

func _ready():
	updateSettingsList()

func updateSettingsList():
	settings_list.setVars(OPTIONS.sounds.getSettingsWithValues())

func _on_settings_list_on_var_change(id: Variant, value: Variant) -> void:
	OPTIONS.sounds.setSettingValue(id, value)
