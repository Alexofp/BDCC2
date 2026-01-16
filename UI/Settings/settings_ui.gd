extends Control

@onready var graphics: Control = %Graphics
@onready var default_settings_button: Button = %DefaultSettingsButton
@onready var tab_container: TabContainer = %TabContainer

signal onSavePressed
signal onCancelPressed

func _on_save_button_pressed() -> void:
	OPTIONS.saveToFile()
	onSavePressed.emit()

func _on_cancel_button_pressed() -> void:
	OPTIONS.loadFromFile()
	onCancelPressed.emit()

func _on_default_settings_button_pressed() -> void:
	if(graphics.visible):
		OPTIONS.graphics.resetToDefaults()
		graphics.updateSettingsList()

func _on_tab_container_tab_changed(_tab: int) -> void:
	updateDefaultsButtons.call_deferred()
	
func updateDefaultsButtons():
	if(!default_settings_button):
		return
	default_settings_button.visible = false
	var theCurrentTab:Control = tab_container.get_current_tab_control()
	if(theCurrentTab && theCurrentTab.has_method("shouldShowDefaultsButton") && theCurrentTab.shouldShowDefaultsButton()): #Graphics tab
		default_settings_button.visible = true
