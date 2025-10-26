extends PanelContainer

@onready var fetishes_edit_ui: VBoxContainer = %FetishesEditUI

signal onSave(fetishHolder:FetishHolder)
signal onCancel

func setFetishHolder(_fetishHolder:FetishHolder):
	fetishes_edit_ui.setFetishHolder(_fetishHolder)

func setFetishHolderCopy(_fetishHolder:FetishHolder):
	var newHolder := FetishHolder.new()
	newHolder.loadData(_fetishHolder.saveData().duplicate(true))
	fetishes_edit_ui.setFetishHolder(newHolder)

func _on_save_button_pressed() -> void:
	onSave.emit(fetishes_edit_ui.fetishes)

func _on_cancel_button_pressed() -> void:
	onCancel.emit()
