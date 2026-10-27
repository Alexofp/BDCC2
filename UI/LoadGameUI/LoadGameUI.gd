extends VBoxContainer

@onready var delete_button: Button = %DeleteButton
@onready var play_button: Button = %PlayButton
@onready var save_desc_label: Label = %SaveDescLabel
@onready var select_save_list_ui: VBoxContainer = %SelectSaveListUI
@onready var confirm_delete_dialog: ConfirmationDialog = %ConfirmDeleteDialog
@onready var new_game_button: Button = %NewGameButton
@onready var multiplayer_var_list: VarList = %MultiplayerVarList

var info:GameShortInfo
var multiplayerData:StartGameMultiplayer = StartGameMultiplayer.new()

signal onBackPressed
signal onPlayPressed(_info:GameShortInfo)
signal onNewGamePressed

# If true, no signal will be emitted
@export var justLoadGame:bool = true

func _ready() -> void:
	updateMultiplayerStuff()

func updateMultiplayerStuff():
	multiplayer_var_list.setVars(multiplayerData.getSettings())

func _on_select_save_list_ui_on_entry_selected(_game: GameShortInfo) -> void:
	info = _game
	updateSelectedGame.call_deferred()

func updateSelectedGame():
	delete_button.disabled = (info == null)
	play_button.disabled = delete_button.disabled || (info && info.corrupted)
	multiplayer_var_list.visible = !play_button.disabled
	
	if(!info):
		save_desc_label.text = "Press the New Game button below to create a new prison."
		return
	if(info.corrupted):
		save_desc_label.text = "This save seems to be corrupted. You can not load it. Sorry.\n"+"Save name: "+info.savePath.get_file()
		return
	
	var theLines:Array[String]
	theLines.append("Name: "+info.prisonName)
	theLines.append("Game mode: "+info.getGameModeName())
	theLines.append("Player's character name: "+info.playerName)
	theLines.append("")
	theLines.append("Time played: "+str(Util.getTimeStringShort(info.timePlayed)))
	theLines.append("Game version: "+info.gameVersion)
	theLines.append("Save name: "+info.savePath.get_file())
	
	save_desc_label.text = Util.join(theLines, "\n")

func _on_open_folder_button_pressed() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(SAVE.SAVES_FOLDER))

func _on_back_button_pressed() -> void:
	onBackPressed.emit()

func _on_play_button_pressed() -> void:
	if(!info):
		return
	if(justLoadGame):
		GM.loadSavedGame(info.savePath, multiplayerData)
		return
	onPlayPressed.emit(info)

func _on_delete_button_pressed() -> void:
	if(!info):
		return
	confirm_delete_dialog.popup_centered()

func updateList():
	select_save_list_ui.populateList()

func _on_confirm_delete_dialog_confirmed() -> void:
	if(!info || info.savePath.is_empty() || !info.savePath.begins_with(SAVE.SAVES_FOLDER)):
		return
	
	DirAccess.remove_absolute(info.savePath)
	info = null
	updateList()
	updateSelectedGame()

func _on_new_game_button_pressed() -> void:
	onNewGamePressed.emit()

func _on_multiplayer_var_list_on_var_change(id: Variant, value: Variant) -> void:
	if(multiplayerData.applySetting(id, value)):
		updateMultiplayerStuff()
