extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/Sandbox/Sandbox.tscn")

func _on_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/IngameEditor/build_test.tscn")

func _on_preview_maker_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/PreviewMaker/preview_maker.tscn")
