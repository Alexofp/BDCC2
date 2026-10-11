extends Control
class_name StartGameUI

@onready var tabs: TabContainer = %Tabs
@onready var first_tab_var_list: VarList = %FirstTabVarList
@onready var gamemode_var_list: VarList = %GamemodeVarList
@onready var gamemode: Control = %Gamemode
@onready var settings: Control = %Settings
@onready var player: Control = %Player
@onready var population: Control = %Population
@onready var overview: Control = %Overview
@onready var multiplayer_var_list: VarList = %MultiplayerVarList
#@onready var player_doll_display_ui: SubViewportContainer = %PlayerDollDisplayUI
#@onready var player_preset_select: VBoxContainer = %PlayerPresetSelect
@onready var start_game_button: Button = %StartGameButton
@onready var reason_label: Label = %ReasonLabel
@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var preset_selector_ui: HBoxContainer = %PresetSelectorUI
@onready var population_list_ui: HBoxContainer = %PopulationListUI

var game:StartGameHolder = StartGameHolder.new()


signal onCancelPressed
signal onStartPressed(_game:StartGameHolder)

func _ready() -> void:
	tabs.current_tab = 0
	game.resetToDefault()
	updateFirstTab()
	
	preset_selector_ui.setCharHolder(game.playerPreset)
	population_list_ui.setPopulation(game.population)

func updateFirstTab():
	first_tab_var_list.setVars(game.getFirstTabSettings())
	multiplayer_var_list.setVars(game.multiplayer.getSettings())

func _on_first_tab_var_list_on_var_change(id: Variant, value: Variant) -> void:
	game.applyFirstTabSetting(id, value)

func updateSecondTab():
	gamemode_var_list.setVars(game.getSecondTabSettings())

func _on_gamemode_var_list_on_var_change(id: Variant, value: Variant) -> void:
	game.applySecondTabSetting(id, value)



func _on_prev_tab_button_pressed() -> void:
	tabs.select_previous_available()

func _on_next_tab_button_pressed() -> void:
	tabs.select_next_available()

func _on_cancel_button_pressed() -> void:
	onCancelPressed.emit()

func _on_start_game_button_pressed() -> void:
	onStartPressed.emit(game)


func _on_settings_visibility_changed() -> void:
	if(settings && settings.visible):
		updateSecondTab()

func _on_multiplayer_var_list_on_var_change(id: Variant, value: Variant) -> void:
	if(game.multiplayer.applySetting(id, value)):
		updateFirstTab()

#func _on_player_preset_select_on_preset_selected(_preset: CharacterPreset) -> void:
#	game.playerPreset.preset = _preset
#	player_doll_display_ui.loadFromPreset(game.playerPreset.preset)

func _on_overview_visibility_changed() -> void:
	if(overview && overview.visible):
		var theRes:String = game.isReadyGetReason()
		start_game_button.disabled = !theRes.is_empty()
		if(theRes.is_empty()):
			reason_label.visible = false
		else:
			reason_label.visible = true
			reason_label.text = theRes


func _on_tabs_tab_changed(_tab: int) -> void:
	if(game):
		game.updateHolder()

func _on_preset_selector_ui_on_preset_selected(_preset: CharacterPreset) -> void:
	game.playerPreset.preset = _preset

func _on_population_visibility_changed() -> void:
	if(population && population.visible):
		updateThirdTab()

func updateThirdTab():
	if(game):
		game.updateHolder()
	population_list_ui.updatePopulationList()
