extends Control

@onready var chat_panel: PanelContainer = %ChatPanel
@onready var chat_widget: VBoxContainer = %ChatWidget

func _enter_tree() -> void:
	UIHandler.addUI(self, UIHandler.CLOSE_TRYCLOSEMENU_FUNC)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func isUIVisible() -> bool:
	return chat_widget.hasLineEditFocus()

func isGameplayInputBlocked() -> bool:
	return chat_widget.hasLineEditFocus()

#func isMenuInputBlocked() -> bool:
#	return chat_widget.hasLineEditFocus()

func _process(_delta: float) -> void:
	#if(!chat_widget.hasLineEditFocus() && Input.is_action_just_pressed("game_chat") && !UIHandler.hasAnyUIVisible()):
	#	chat_widget.grabLineEditFocus()
	pass

func _unhandled_input(_event: InputEvent) -> void:
	if(visible && _event.is_action_pressed("game_chat") && !UIHandler.hasAnyUIVisible()):
		chat_widget.grabLineEditFocus()

#func _unhandled_input(event: InputEvent) -> void:
	#if(event is InputEventAction):
		#

func tryCloseMenu() -> bool:
	if(chat_widget.hasLineEditFocus()):
		chat_widget.releaseLineEditFocus()
		return true
	return false
