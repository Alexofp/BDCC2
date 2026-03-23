extends Label3D

func _on_delete_timer_timeout() -> void:
	queue_free()
