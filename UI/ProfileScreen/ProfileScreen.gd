extends PanelContainer
@onready var confirm_button: Button = %ConfirmButton
@onready var nickname_line_edit: LineEdit = %NicknameLineEdit

signal onConfirm

func _ready() -> void:
	nickname_line_edit.text = MyProfile.profile.nickname
	updateConfirmButton()

func _on_confirm_button_pressed() -> void:
	MyProfile.profile.nickname = getNewName()
	MyProfile.newPlayer = false
	MyProfile.save()
	onConfirm.emit()

func updateConfirmButton():
	confirm_button.disabled = getNewName().is_empty()

func getNewName() -> String:
	return nickname_line_edit.text.strip_edges()

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()

func _on_nickname_line_edit_text_changed(_new_text: String) -> void:
	updateConfirmButton()
