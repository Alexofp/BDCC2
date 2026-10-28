extends Control

@onready var welcome_panel: PanelContainer = %WelcomePanel
@onready var motd_label: RichTextLabel = %MotdLabel
@onready var preset_selector_ui: HBoxContainer = %PresetSelectorUI
@onready var make_character_button: Button = %MakeCharacterButton
@onready var join_button: Button = %JoinButton

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

func loadData(_data:Dictionary):
	var theMotd:String = SAVE.loadStr(_data, "motd")
	if(!theMotd.is_empty()):
		setMOTD(theMotd)
	if(_data.has("charName")):
		var theCharName:String = SAVE.loadStr(_data, "charName")
		make_character_button.visible = false
		join_button.visible = true
		join_button.text = "Join as "+theCharName
	else:
		make_character_button.visible = true
		join_button.visible = false
	

func _on_motd_label_meta_clicked(_meta: Variant) -> void:
	if(!(_meta is String)):
		return
	var theStr:String = _meta.strip_edges()
	if(theStr.begins_with("https://")): # Is dis secure now?
		OS.shell_open(theStr)

func _on_join_button_pressed() -> void:
	if(!GM.main.gameMode):
		return
	GM.main.gameMode.askToJoinAsMyCharacter()
