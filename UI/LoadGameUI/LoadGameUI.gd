extends VBoxContainer

@onready var delete_button: Button = %DeleteButton
@onready var play_button: Button = %PlayButton
@onready var save_desc_label: Label = %SaveDescLabel
@onready var select_save_list_ui: VBoxContainer = %SelectSaveListUI
@onready var confirm_delete_dialog: ConfirmationDialog = %ConfirmDeleteDialog

var info:GameShortInfo

signal onBackPressed
signal onPlayPressed(_info:GameShortInfo)

# If true, no signal will be emitted
@export var justLoadGame:bool = true

func _on_select_save_list_ui_on_entry_selected(_game: GameShortInfo) -> void:
	info = _game
	updateSelectedGame.call_deferred()

func updateSelectedGame():
	delete_button.disabled = (info == null)
	play_button.disabled = delete_button.disabled || (info && info.corrupted)
	
	if(!info):
		save_desc_label.text = ""
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
		GM.loadSavedGame(info.savePath)
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
	updateList()
