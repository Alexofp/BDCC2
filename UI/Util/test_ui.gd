extends PanelContainer

func _enter_tree() -> void:
	UIHandler.addUI(self)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func _on_close_button_pressed() -> void:
	queue_free()
