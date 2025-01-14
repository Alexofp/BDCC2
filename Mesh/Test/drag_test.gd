extends Node3D

@onready var selected_object: MeshInstance3D = $MeshInstance3D
var move_axis: Vector3 = Vector3.ZERO  # The active axis for movement constraint
var sensitivity: float = 0.01  # Adjust the speed of movement

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		match event.physical_keycode:
			KEY_X:
				# Constrain movement to the object's local X axis
				move_axis = selected_object.transform.basis.x.normalized()
			KEY_Y:
				# Constrain movement to the object's local Y axis
				move_axis = selected_object.transform.basis.y.normalized()
			KEY_Z:
				# Constrain movement to the object's local Z axis
				move_axis = selected_object.transform.basis.z.normalized()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		# Clear movement constraint when the mouse button is released
		move_axis = Vector3.ZERO

	elif event is InputEventMouseMotion:
		if selected_object and move_axis != Vector3.ZERO:
			_move_along_axis(event.relative)

func _move_along_axis(mouse_delta: Vector2):
	# Translate the 2D mouse movement to 3D movement along the constrained axis
	# 1. Get the camera direction vector (projected to 3D space)
	var camera = get_viewport().get_camera_3d()
	var camera_to_object = (selected_object.global_transform.origin - camera.global_transform.origin).normalized()
	
	# 2. Project the mouse movement onto the selected axis
	var screen_delta = Vector3(mouse_delta.x, -mouse_delta.y, 0) * sensitivity
	
	# 3. Convert screen delta to 3D movement along the constrained axis
	var movement_3d = camera.global_transform.basis.x * screen_delta.x + camera.global_transform.basis.y * screen_delta.y

	# Project the movement onto the constrained axis
	var constrained_movement = move_axis * move_axis.dot(movement_3d)
	
	# 4. Translate the object by the constrained movement
	selected_object.translate_object_local(constrained_movement)
