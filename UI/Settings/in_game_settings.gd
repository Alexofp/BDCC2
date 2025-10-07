extends Control

signal onSavePressed
signal onCancelPressed

func _enter_tree() -> void:
	UIHandler.addUI(self, UIHandler.CLOSE_TRYCLOSEMENU_FUNC)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func _on_settings_ui_on_save_pressed() -> void:
	onSavePressed.emit()

func _on_settings_ui_on_cancel_pressed() -> void:
	onCancelPressed.emit()

func tryCloseMenu() -> bool:
	onCancelPressed.emit()
	return true
