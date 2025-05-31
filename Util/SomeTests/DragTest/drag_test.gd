extends Node3D

@export var base_drag_speed: float = 0.002  # Base speed for dragging, will be adjusted by distance

var is_dragging: bool = false
var initial_position: Vector3 = Vector3.ZERO
var initial_mouse_pos: Vector2 = Vector2.ZERO
var drag_axis: Vector3 = Vector3.ZERO  # Set to lock on a specific axis

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_G:
					# Start dragging on 'G' key press
					start_dragging()
				KEY_X:
					# Lock movement to the X axis
					if is_dragging:
						drag_axis = Vector3(1, 0, 0)  # Lock to global X
				KEY_Y:
					# Lock movement to the Y axis
					if is_dragging:
						drag_axis = Vector3(0, -1, 0)  # Lock to global Y
				KEY_Z:
					# Lock movement to the Z axis
					if is_dragging:
						drag_axis = Vector3(0, 0, -1)  # Lock to global Z

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and is_dragging:
			# Confirm the drag and stop when left-click is pressed
			stop_dragging()
		elif event.button_index == MOUSE_BUTTON_RIGHT and is_dragging:
			# Cancel the drag and reset the position when right-click is pressed
			cancel_dragging()

func start_dragging() -> void:
	is_dragging = true
	initial_position = global_transform.origin
	initial_mouse_pos = get_viewport().get_mouse_position()
	drag_axis = Vector3.ZERO  # Reset axis lock

func stop_dragging() -> void:
	is_dragging = false

func cancel_dragging() -> void:
	is_dragging = false
	global_transform.origin = initial_position  # Reset to the starting position

func _process(delta: float) -> void:
	if is_dragging:
		var current_mouse_pos = get_viewport().get_mouse_position()
		var mouse_delta = current_mouse_pos - initial_mouse_pos

		# Calculate the distance from the camera to the object for adaptive drag speed
		var camera = get_viewport().get_camera_3d()
		if camera:
			var distance_to_camera = camera.global_transform.origin.distance_to(global_transform.origin)
			var adjusted_drag_speed = base_drag_speed * distance_to_camera  # Adjust drag speed based on distance

			# Calculate movement in view space or world space depending on axis lock
			var movement = Vector3.ZERO
			if drag_axis == Vector3.ZERO:
				# No axis lock: Move in view space
				var right_movement = camera.global_transform.basis.x * mouse_delta.x * adjusted_drag_speed
				var up_movement = camera.global_transform.basis.y * -mouse_delta.y * adjusted_drag_speed
				movement = right_movement + up_movement
			else:
				# Axis locked: Move in world space along the locked axis
				var axis_movement = drag_axis * (mouse_delta.x + mouse_delta.y) * adjusted_drag_speed
				movement = axis_movement

			# Update position based on initial position and calculated movement
			global_transform.origin = initial_position + movement
