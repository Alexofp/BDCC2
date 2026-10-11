extends HBoxContainer

@onready var character_desc_label: RichTextLabel = %CharacterDescLabel
@onready var randomize_h_box: HBoxContainer = %RandomizeHBox
@onready var randomize_settings_button: Button = %RandomizeSettingsButton
@onready var randomize_settings_panel: PanelContainer = %RandomizeSettingsPanel
@onready var randomize_settings_list: VBoxContainer = %RandomizeSettingsList
@onready var randomize_button: Button = %RandomizeButton
@onready var char_item_list: ItemList = %CharItemList
@onready var player_doll_display_ui: SubViewportContainer = %PlayerDollDisplayUI
@onready var edit_buttons: VBoxContainer = %EditButtons

@export var allowEdit:bool = true
@export var charCreatorNode:Control
@export var charCreatorHide:Control
var presetSelectorUI:Control

var fullInfo:bool = false
var charHolder:StartGameCharHolder
var population:Array[StartGameCharHolder]

const PRESET_SELECTOR_UI = preload("res://Game/UI/StartGameUI/PresetSelectorUI.tscn")

func _ready() -> void:
	randomize_settings_panel.visible = false
	if(!allowEdit):
		edit_buttons.visible = false
	
func setPopulation(_pops:Array[StartGameCharHolder]):
	population = _pops
	charHolder = null
	updatePopulationList()
	updateSelectedChar()

func updatePopulationList():
	if(charHolder && !population.has(charHolder)):
		charHolder = null
		updateSelectedChar()
	
	char_item_list.clear()
	var _i:int = 0
	for _char:StartGameCharHolder in population:
		var _name:String = _char.getPopulationListName()
		char_item_list.add_item(_name)
		if(_char == charHolder):
			char_item_list.select(_i)
		_i += 1

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

func _on_randomize_settings_button_pressed() -> void:
	randomize_settings_panel.visible = !randomize_settings_panel.visible
	if(randomize_settings_panel.visible):
		randomize_settings_button.text = ">"
	else:
		randomize_settings_button.text = "<"

func updateSelectedChar():
	updateCharacterDescLabel()
	player_doll_display_ui.loadFromPreset(charHolder.preset if charHolder else null)

func _on_char_item_list_item_selected(_index: int) -> void:
	if(_index < 0 || _index >= population.size()):
		return
	charHolder = population[_index]
	updateSelectedChar()

func _on_randomize_button_pressed() -> void:
	if(!charHolder || !charHolder.preset || !charHolder.preset.generated):
		return
	var theSettings:RandomizeSettingsHolder = randomize_settings_list.settings
	charHolder.preset.doRandomize(theSettings)
	updateSelectedChar()
	updatePopulationList()

func _on_edit_button_pressed() -> void:
	if(!charCreatorNode || !charCreatorHide || !allowEdit || !charHolder):
		return
	presetSelectorUI = PRESET_SELECTOR_UI.instantiate()
	charCreatorHide.visible = false
	presetSelectorUI.addConfirm = true
	charCreatorNode.add_child(presetSelectorUI)
	presetSelectorUI.setCharHolder(charHolder)
	presetSelectorUI.onConfirm.connect(onPresetSelectorConfirm)

func onPresetSelectorConfirm():
	charCreatorHide.visible = true
	presetSelectorUI.queue_free()
	presetSelectorUI = null
	updateSelectedChar()
	updatePopulationList()
