extends Control

@onready var welcome_panel: PanelContainer = %WelcomePanel
@onready var motd_label: RichTextLabel = %MotdLabel
@onready var preset_selector_ui: HBoxContainer = %PresetSelectorUI

func _on_disconnect_button_pressed() -> void:
	GM.errorOutToMainMenu("You have disconnected from the server!")

func _on_make_character_button_pressed() -> void:
	welcome_panel.visible = false
	var newCharHolder:StartGameCharHolder = StartGameCharHolder.new()
	newCharHolder.doResetToDefaultPC()
	preset_selector_ui.setCharHolder(newCharHolder)
	preset_selector_ui.visible = true

func _on_preset_selector_ui_on_confirm(_preset:CharacterPreset) -> void:
	if(!GM.main.gameMode):
		return
	GM.main.gameMode.askToJoinWithPreset(_preset)

func setMOTD(_text:String):
	motd_label.text = _text


func _on_motd_label_meta_clicked(_meta: Variant) -> void:
	if(!(_meta is String)):
		return
	var theStr:String = _meta.strip_edges()
	if(theStr.begins_with("https://")): # Is dis secure now?
		OS.shell_open(theStr)
