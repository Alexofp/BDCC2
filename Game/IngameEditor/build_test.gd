extends Node3D

func _on_player_editor_on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn")
