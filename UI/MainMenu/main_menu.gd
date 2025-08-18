extends Control

func _on_play_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Game/Sandbox/Sandbox.tscn")
	#get_tree().change_scene_to_file("res://Game/Main.tscn")
	GM.startGame("res://Maps/Prison/prison.tscn", GameMode.Sandbox)

func _on_char_editor_button_pressed() -> void:
	GM.startGame("res://Maps/Prison/prison.tscn", GameMode.CharacterCreator)

func _on_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/IngameEditor/build_test.tscn")

func _on_preview_maker_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/PreviewMaker/preview_maker.tscn")
