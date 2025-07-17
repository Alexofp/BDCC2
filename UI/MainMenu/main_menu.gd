extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/Sandbox/Sandbox.tscn")

func _on_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/IngameEditor/build_test.tscn")
