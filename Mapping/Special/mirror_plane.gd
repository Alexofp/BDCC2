extends PropBasic

@export var world_size:Vector2 = Vector2(1.0, 1.0):
	set(new_world_size):
		var changed := world_size != new_world_size
		world_size = new_world_size
		if(is_node_ready()):
			var quad: QuadMesh = _mesh_instance_3d.mesh
			quad.size = new_world_size
			_camera_3d.size = new_world_size.y
			_visible_on_screen_notifier_3d.aabb = AABB(
				Vector3(-0.5 * new_world_size.x, -0.5 * new_world_size.y, 0.0),
				Vector3(new_world_size.x, new_world_size.y, 0.1)
			)
		if(changed):
			notifySetEditorValue("mirror_width", new_world_size.x)
			notifySetEditorValue("mirror_height", new_world_size.y)
@export var framebuffer_size:Vector2i = Vector2i(512, 512):
	set(new_framebuffer_size):
		var changed := maxi(framebuffer_size.x, framebuffer_size.y) != maxi(new_framebuffer_size.x, new_framebuffer_size.y)
		framebuffer_size = new_framebuffer_size
		if(is_node_ready()):
			_sub_viewport.size = new_framebuffer_size
		if(changed):
			notifySetEditorValue("resolution", maxi(new_framebuffer_size.x, new_framebuffer_size.y))

var mirror_width:float:
	get:
		return world_size.x
	set(value):
		var old_resolution := resolution
		world_size.x = value
		resolution = old_resolution
var mirror_height:float:
	get:
		return world_size.y
	set(value):
		var old_resolution := resolution
		world_size.y = value
		resolution = old_resolution
var resolution:int:
	get:
		return maxi(framebuffer_size.x, framebuffer_size.y)
	set(value):
		if world_size.x < world_size.y:
			framebuffer_size = Vector2i(int(value * world_size.x / world_size.y), value).maxi(1)
		else:
			framebuffer_size = Vector2i(value, int(value * world_size.y / world_size.x)).maxi(1)

@onready var _mesh_instance_3d: MeshInstance3D = %MeshInstance3D
@onready var _sub_viewport: SubViewport = %SubViewport
@onready var _camera_3d: Camera3D = %Camera3D
@onready var _visible_on_screen_notifier_3d: VisibleOnScreenNotifier3D = %VisibleOnScreenNotifier3D

func _ready() -> void:
	var quad: QuadMesh = _mesh_instance_3d.mesh
	quad.size = world_size
	_camera_3d.size = world_size.y
	_visible_on_screen_notifier_3d.aabb = AABB(
		Vector3(-0.5 * world_size.x, -0.5 * world_size.y, 0.0),
		Vector3(world_size.x, world_size.y, 0.1)
	)
	_sub_viewport.size = framebuffer_size
	_sub_viewport.world_3d = get_world_3d()

func _process(_delta: float) -> void:
	_deferred_camera_update.call_deferred()

func _deferred_camera_update() -> void:
	if(!_visible_on_screen_notifier_3d.is_on_screen()):
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return

	var parent_viewport := get_viewport()
	if(!parent_viewport):
		return

	var player_camera := parent_viewport.get_camera_3d()
	if(!player_camera):
		return

	var local := to_local(player_camera.get_global_transform_interpolated().origin)
	if(local.z < 0):
		# camera is behind mirror
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return

	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE

	_camera_3d.global_transform = global_transform * Transform3D(Basis.FLIP_X * Basis.FLIP_Z, Vector3(local.x, local.y, -local.z))
	_camera_3d.set_frustum(world_size.y, Vector2(local.x, -local.y), absf(local.z), 4000.0)

func getEditorOptions() -> Dictionary:
	return {
		"mirror_width": {
			name = "Mirror Width",
			type = "float",
		},
		"mirror_height": {
			name = "Mirror Height",
			type = "float",
		},
		"resolution": {
			name = "Resolution",
			type = "int",
		},
	}

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_MIRRORPLANE

func applyEditorOption(_id, _value):
	match _id:
		"mirror_width":
			mirror_width = _value
		"mirror_height":
			mirror_height = _value
		"resolution":
			resolution = _value
		_:
			super.applyEditorOption(_id, _value)
