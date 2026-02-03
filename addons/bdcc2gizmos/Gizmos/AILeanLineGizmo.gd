extends EditorNode3DGizmoPlugin

func _get_gizmo_name():
	return "AI Lean Line"

func _has_gizmo(node:Node3D) -> bool:
	return node is AILeanLine

func _init():
	create_material("main", Color(1, 0, 0))
	create_handle_material("handles")

const ARROW_HEIGHT = 1.0
const ARROW_LEN = 0.5
const ARROW_SIZE = 0.1

func _redraw(gizmo:EditorNode3DGizmo):
	gizmo.clear()

	var n := gizmo.get_node_3d()
	var w :float= n.width
	
	var line := PackedVector3Array([
		Vector3(-w, 0, 0),
		Vector3( w, 0, 0),
		Vector3(-w, 0.01, 0),
		Vector3( w, 0.01, 0),
		Vector3(-w, 0.02, 0),
		Vector3( w, 0.02, 0),
		Vector3(0.0, ARROW_HEIGHT, 0),
		Vector3(0.0, ARROW_HEIGHT, ARROW_LEN),
		Vector3(ARROW_SIZE, ARROW_HEIGHT, ARROW_LEN - ARROW_SIZE),
		Vector3(0.0, ARROW_HEIGHT, ARROW_LEN),
		Vector3(-ARROW_SIZE, ARROW_HEIGHT, ARROW_LEN - ARROW_SIZE),
		Vector3(0.0, ARROW_HEIGHT, ARROW_LEN),
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, ARROW_HEIGHT*2.0, 0.0),
	])
	gizmo.add_lines(line, get_material("main", gizmo), false)

	var handles := PackedVector3Array()
	handles.push_back(Vector3( w, 0, 0))
	handles.push_back(Vector3(-w, 0, 0))
	gizmo.add_handles(handles, get_material("handles", gizmo), [])

func _get_handle_name(_gizmo:EditorNode3DGizmo, _handle_id:int, _secondary:bool) -> String:
	match _handle_id:
		0: return "+X"
		1: return "-X"
	return "ERROR?"

func _get_handle_value(_gizmo:EditorNode3DGizmo, _handle_id:int, _secondary:bool):
	var n := _gizmo.get_node_3d()
	return n.width

func _set_handle(
	gizmo: EditorNode3DGizmo,
	handle_id: int,
	secondary: bool,
	camera: Camera3D,
	screen_pos: Vector2
):
	var n := gizmo.get_node_3d()
	if not n:
		return

	# World-space ray from camera
	var ray_from = camera.project_ray_origin(screen_pos)
	var ray_dir = camera.project_ray_normal(screen_pos)
	# Ensure ray_dir is normalized
	ray_dir = ray_dir.normalized()

	# World-space X axis line (through node origin)
	var L0 = n.global_transform.origin
	# Use world-space X axis (accounting for node rotation & scale)
	var Ld = n.global_transform.basis.x
	# If scale is present, normalize to get direction
	var Ld_len = Ld.length()
	if Ld_len == 0.0:
		return
	Ld = Ld / Ld_len

	# Solve closest approach between ray (R0 + t*Rd) and line (L0 + s*Ld)
	var w0 = ray_from - L0
	var a = ray_dir.dot(ray_dir)       # = 1.0 since normalized, but keep general
	var b = ray_dir.dot(Ld)
	var c = Ld.dot(Ld)                 # = 1.0 since normalized
	var d = ray_dir.dot(w0)
	var e = Ld.dot(w0)

	var D = a * c - b * b
	var s = 0.0

	if abs(D) < 1e-8:
		# Parallel (or nearly). fallback: project ray origin onto axis
		# e = Ld.dot(w0) gives the scalar along Ld from L0 to ray_from.
		s = e
	else:
		# solved from linear system:
		# a t - b s = -d
		# -b t + c s = -e
		# s = (a*e - b*d) / D
		s = (a * e - b * d) / D

	# s is signed distance along Ld from L0. Set width to absolute value.
	n.width = abs(s)
	# optional clamp/min:
	# n.width = clamp(n.width, 0.001, 100.0)

	n.update_gizmos()
