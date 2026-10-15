extends HBoxContainer

@onready var player_doll_display_ui: SubViewportContainer = %PlayerDollDisplayUI
@onready var player_preset_select: VBoxContainer = %PlayerPresetSelect

@onready var randomize_h_box: HBoxContainer = %RandomizeHBox
@onready var randomize_settings_button: Button = %RandomizeSettingsButton
@onready var randomize_button: Button = %RandomizeButton

@onready var randomize_settings_panel: PanelContainer = %RandomizeSettingsPanel
@onready var randomize_settings_list: VBoxContainer = %RandomizeSettingsList
@onready var character_desc_label: RichTextLabel = %CharacterDescLabel
@onready var confirm_button: Button = %ConfirmButton
@onready var delete_preset_button: Button = %DeletePresetButton
@onready var delete_preset_dialog: ConfirmationDialog = %DeletePresetDialog

@export var charCreatorNode:Control
@export var charCreatorHide:Control
@export var addGenerated:bool = true
@export var addConfirm:bool = false

var fullInfo:bool = false

var charHolder:StartGameCharHolder
var charCreator:Control
const CHARACTER_CREATOR_STANDALONE = preload("res://UI/DollDisplayUI/CharacterCreatorStandalone.tscn")

#var generatedPreset:CharacterPreset

signal onPresetSelected(_preset:CharacterPreset)
signal onConfirm

func setCharHolder(_holder:StartGameCharHolder):
	charHolder = _holder
	updatePlayerPresetList()
	player_preset_select.setSelectedPreset(charHolder.preset if charHolder else null, true, true)

func updatePlayerPresetList():
	if(!charHolder):
		player_preset_select.setExtraPresets([])
		return
	if(charHolder.preset && charHolder.preset.generated):
		var _ar:Array[CharacterPreset] = [charHolder.preset]
		player_preset_select.setExtraPresets(_ar)
	elif(addGenerated):
		var _generatedPreset:CharacterPreset = CharacterPreset.new()
		_generatedPreset.doRandomize()
		_generatedPreset.generated = true
		_generatedPreset.embedded = true
		var _ar:Array[CharacterPreset] = [_generatedPreset]
		player_preset_select.setExtraPresets(_ar)
	updateSelectedPreset()
	
func _ready() -> void:
	randomize_settings_panel.visible = false
	delete_preset_button.visible = false
	confirm_button.visible = addConfirm

func showCharCreator(_preset:CharacterPreset = null):
	if(charCreator):
		return
	if(charCreatorHide):
		charCreatorHide.visible = false
	charCreator = CHARACTER_CREATOR_STANDALONE.instantiate()
	if(charCreatorNode):
		charCreatorNode.add_child(charCreator)
	else:
		add_child(charCreator)
	if(!_preset):
		charCreator.newCharacter()
	else:
		charCreator.loadPreset(_preset)
	charCreator.onConfirm.connect(onCharCreatorConfirmed)
	charCreator.onCancel.connect(onCharCreatorCancel)

func onCharCreatorCancel():
	removeCharCreator()

func onCharCreatorConfirmed(_preset:CharacterPreset):
	removeCharCreator()
	if(_preset):
		if(_preset.generated):
			charHolder.preset = _preset
			#generatedPreset = _preset
			player_preset_select.setSelectedPreset(charHolder.preset, true, true)
		else:
			charHolder.preset = _preset
			_preset.doSave()
			GM.presets.rescanUserPresets()
			player_preset_select.setSelectedPresetByPath(_preset.filename, true, true)
			#player_preset_select.setSelectedPreset(charHolder.preset, true, true)
	#newPreset.savePreset(theName)
	#GM.presets.rescanUserPresets()
	#character_preset_selector.updateAll()

func removeCharCreator():
	if(!charCreator):
		return
	charCreator.queue_free()
	charCreator = null
	if(charCreatorHide):
		charCreatorHide.visible = true

func _on_new_preset_button_pressed() -> void:
	showCharCreator()

func _on_edit_preset_button_pressed() -> void:
	showCharCreator(charHolder.preset)

func _on_player_preset_select_on_preset_selected(_preset: CharacterPreset) -> void:
	#fullInfo = false
	charHolder.preset = _preset
	#preset = _preset
	player_doll_display_ui.loadFromPreset(charHolder.preset)
	onPresetSelected.emit(charHolder.preset)
	updateSelectedPreset()

func updateSelectedPreset():
	updateCharacterDescLabel()
	if(!charHolder.preset):
		return
	randomize_h_box.visible = charHolder.preset.generated
	delete_preset_button.visible = charHolder.preset.canBeDeleted()

func _on_randomize_button_pressed() -> void:
	if(!charHolder || !charHolder.preset || !charHolder.preset.generated):
		return
	var theSettings:RandomizeSettingsHolder = randomize_settings_list.settings
	charHolder.preset.doRandomize(theSettings)
	_on_player_preset_select_on_preset_selected(charHolder.preset)
	updatePlayerPresetList()


func _on_randomize_settings_button_pressed() -> void:
	randomize_settings_panel.visible = !randomize_settings_panel.visible
	if(randomize_settings_panel.visible):
		randomize_settings_button.text = ">"
	else:
		randomize_settings_button.text = "<"

func updateCharacterDescLabel():
	if(!charHolder || !charHolder.preset):
		character_desc_label.text = ""
		return
	var _preset:CharacterPreset = charHolder.preset
	var theLines:Array[String] = _preset.getDescriptionLines(fullInfo)
	
	character_desc_label.text = Util.join(theLines, "\n")

func _on_show_full_info_button_pressed() -> void:
	fullInfo = !fullInfo
	updateCharacterDescLabel()

func _on_confirm_button_pressed() -> void:
	onConfirm.emit()

func _on_delete_preset_button_pressed() -> void:
	if(!charHolder || !charHolder.preset || !charHolder.preset.canBeDeleted()):
		return
	delete_preset_dialog.popup_centered()

func _on_delete_preset_dialog_confirmed() -> void:
	if(!charHolder || !charHolder.preset || !charHolder.preset.canBeDeleted()):
		return
	if(!charHolder.preset.deletePreset()):
		return
	#charHolder = null
	charHolder.preset = null
	player_preset_select.setSelectedPreset(null)
	player_doll_display_ui.loadFromPreset(null)
	updateSelectedPreset()
	updatePlayerPresetList()
