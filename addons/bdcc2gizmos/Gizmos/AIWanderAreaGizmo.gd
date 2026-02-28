extends EditorNode3DGizmoPlugin

func _get_gizmo_name():
	return "AI Wander Area"

func _has_gizmo(node:Node3D) -> bool:
	return node is AIWanderArea

func _init():
	create_material("main", Color(1, 0, 0))
	create_handle_material("handles")

const CIRCLE_SEGMENTS := 16

func _redraw(gizmo:EditorNode3DGizmo):
	gizmo.clear()

	var n := gizmo.get_node_3d()

	#var lines := PackedVector3Array()
	#lines.push_back(Vector3(0, node3d.radius, 0))
	#lines.push_back(Vector3(0, 0, 0))

	var pts := PackedVector3Array()
	for _i in CIRCLE_SEGMENTS:
		var a0 = TAU * _i / CIRCLE_SEGMENTS
		var a1 = TAU * (_i + 1) / CIRCLE_SEGMENTS

		var p0 = Vector3(cos(a0), 0, sin(a0)) * n.radius
		var p1 = Vector3(cos(a1), 0, sin(a1)) * n.radius

		pts.push_back(p0)
		pts.push_back(p1)

	var handles := PackedVector3Array()
	handles.push_back(Vector3(n.radius, 0, 0)) # handle_id 0
	#handles.push_back(Vector3(0, 1, 0))
	#handles.push_back(Vector3(0, node3d.my_custom_value, 0))

	gizmo.add_lines(pts, get_material("main", gizmo), false)
	gizmo.add_handles(handles, get_material("handles", gizmo), [])

func _get_handle_name(_gizmo:EditorNode3DGizmo, _handle_id:int, _secondary:bool):
	return "radius"

func _get_handle_value(_gizmo:EditorNode3DGizmo, _handle_id:int, _secondary:bool):
	var n := _gizmo.get_node_3d()
	return n.radius

func _set_handle(
	gizmo: EditorNode3DGizmo,
	handle_id: int,
	secondary: bool,
	camera: Camera3D,
	screen_pos: Vector2
):
	var n := gizmo.get_node_3d()

	# Drag in XZ plane
	var plane := Plane.PLANE_XZ
	plane = n.global_transform * plane

	var ray_from = camera.project_ray_origin(screen_pos)
	var ray_dir = camera.project_ray_normal(screen_pos)

	var hit = plane.intersects_ray(ray_from, ray_dir)
	if hit == null:
		return

	var local = n.global_transform.affine_inverse() * hit
	n.radius = maxf(0.01, local.length())
	n.update_gizmos()
