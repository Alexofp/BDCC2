extends PriorityCamera
class_name FreeCamera

func _ready() -> void:
	pass

func _enter_tree() -> void:
	super._enter_tree()
	UIHandler.addMouseCapturer(self)

func _exit_tree() -> void:
	super._exit_tree()
	UIHandler.removeMouseCapturer(self)

func shouldCaptureMouse() -> bool:
	if(!UIHandler.hasAnyUIVisible() && isActive()):
		return true
	return false

func _process(_delta: float) -> void:
	if(UIHandler.hasAnyUIVisible() || UIHandler.isMenuInputBlocked()):
		return
	if(!isActive()):
		return
	const speed := 2.0
	var vel := Vector3.ZERO
	if(Input.is_action_pressed("move_forward") || (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))):
		vel += Vector3.FORWARD * speed
	if(Input.is_action_pressed("move_back")):
		vel += Vector3.BACK * speed
	if(Input.is_action_pressed("move_left")):
		vel += Vector3.LEFT * speed
	if(Input.is_action_pressed("move_right")):
		vel += Vector3.RIGHT * speed
	if(Input.is_action_pressed("move_jump")):
		vel += Vector3.UP * speed
	if(Input.is_action_pressed("move_sprint")):
		vel *= 5.0
	if(Input.is_action_just_pressed("camera_zoomin")):
		fov = clamp((fov*0.9), 1.0, 150.0)
	if(Input.is_action_just_pressed("camera_zoomout")):
		fov = clamp((fov*1.1), 1.0, 150.0)
	
	translate_object_local(vel * _delta)

func _input(event: InputEvent) -> void:
	if(!isActive()):
		return
	if(event is InputEventMouseMotion):
		if(UIHandler.hasAnyUIVisible()):
			return
		var mouseD:Vector2 = event.relative
		processCameraMouseMotion(mouseD)

func processCameraMouseMotion(mouseD:Vector2):
	const sensivity = 0.05
	rotateCamera(self, mouseD.x * sensivity, mouseD.y * sensivity)
	
func rotateCamera(theCamera:Node3D, roty:float, rotx:float):
	var rot := theCamera.rotation_degrees
	rot.x = clamp(rot.x - rotx, -90.0, 90)
	rot.y -= roty
	theCamera.rotation_degrees = rot
