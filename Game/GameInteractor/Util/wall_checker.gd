extends Node3D
class_name WallChecker

@onready var wall_checker_start: Marker3D = %WallCheckerStart
@onready var wall_checker_end: Marker3D = %WallCheckerEnd

var ray_cast_query := PhysicsRayQueryParameters3D.new()
var shape_query := PhysicsShapeQueryParameters3D.new()
@onready var global_world : World3D = get_tree().current_scene.get_world_3d()
@onready var space_state := global_world.direct_space_state

@onready var floor_point_mesh: MeshInstance3D = %FloorPointMesh
@onready var wall_point_mesh: MeshInstance3D = %WallPointMesh
@onready var floor_marker: Marker3D = %FloorMarker
@onready var free_space_shape: CollisionShape3D = %FreeSpaceShape
@onready var must_be_filled_space: CollisionShape3D = %MustBeFilledSpace
@onready var must_be_filled_space_2: CollisionShape3D = %MustBeFilledSpace2
@onready var final_pos_marker: Marker3D = %FinalPosMarker

# returns dictionary containing "position", "normal", "collider", "shape"
# returns empty dictionary if nothing hit.
func castRay(start : Vector3, end : Vector3, mask : int = 0x7FFFFFFF, ignore_objects := [], collide_with_areas := false, hit_from_inside := false) -> Dictionary:
	ray_cast_query.collide_with_areas = collide_with_areas
	ray_cast_query.hit_from_inside = hit_from_inside
	ray_cast_query.from = start
	ray_cast_query.to = end
	ray_cast_query.exclude = ignore_objects
	ray_cast_query.collision_mask = mask
	return space_state.intersect_ray(ray_cast_query)

func checkFreeShape(_shape:CollisionShape3D, mask : int = 0x7FFFFFFF, ignore_objects := [], collide_with_areas := false) -> bool:
	shape_query.collide_with_areas = collide_with_areas
	shape_query.collision_mask = mask
	shape_query.exclude = ignore_objects
	shape_query.shape = _shape.shape
	shape_query.transform = _shape.global_transform
	return space_state.intersect_shape(shape_query, 1).is_empty()

func checkFreeShapeSubdivided(_shape:CollisionShape3D, _subdiv:Vector3i, mask : int = 0x7FFFFFFF, ignore_objects := [], collide_with_areas := false) -> float:
	var boxShape := _shape.shape
	if not (boxShape is BoxShape3D):
		push_error("checkFreeShapeSubdivided(): only BoxShape3D is supported!")
		return 0.0

	var sx := maxi(1, _subdiv.x)
	var sy := maxi(1, _subdiv.y)
	var sz := maxi(1, _subdiv.z)

	var fullSize: Vector3 = boxShape.size
	var cellSize: Vector3 = Vector3(fullSize.x / sx, fullSize.y / sy, fullSize.z / sz)
	# Starting corner
	var local_min: Vector3 = -fullSize * 0.5
	
	var query := PhysicsShapeQueryParameters3D.new()
	query.collide_with_areas = collide_with_areas
	query.collision_mask = mask
	query.exclude = ignore_objects

	var smallBox := BoxShape3D.new()
	smallBox.size = cellSize
	query.shape = smallBox

	var total := sx * sy * sz
	var freeCount := 0

	var theGlobalTransform := _shape.global_transform
	for x in sx:
		for y in sy:
			for z in sz:
				var cx := local_min.x + (x + 0.5) * cellSize.x
				var cy := local_min.y + (y + 0.5) * cellSize.y
				var cz := local_min.z + (z + 0.5) * cellSize.z
				var localCenter := Vector3(cx, cy, cz)

				var localOffset := Transform3D(Basis(), localCenter)
				query.transform = theGlobalTransform * localOffset

				var res := space_state.intersect_shape(query, 1)
				if res.is_empty():
					freeCount += 1

	return float(freeCount) / float(total)

func checkCanLean() -> bool:
	var theWallCast := castRay(wall_checker_start.global_position, wall_checker_end.global_position)
	
	#wall_point_mesh.visible = false
	#floor_point_mesh.visible = false
	
	if(theWallCast.is_empty()):
		return false
	
	var theWallPos:Vector3 = theWallCast["position"]
	var theWallNormal:Vector3 = theWallCast["normal"]
	if(abs(theWallNormal.y) > 0.01):
		return false
	#wall_point_mesh.visible = true
	wall_point_mesh.global_position = theWallPos

	var floorRayStart := theWallPos + theWallNormal * 0.1# + Vector3.UP * 0.3
	var floorRayEnd := floorRayStart + Vector3.DOWN * 2.0
	
	var theFloorCast := castRay(floorRayStart, floorRayEnd)
	if(theFloorCast.is_empty()):
		return false
	var theFloorPos:Vector3 = theFloorCast["position"] - theWallNormal * 0.1
	#floor_point_mesh.visible = true
	floor_marker.global_position = theFloorPos
	
	#var ry := -theWallNormal.normalized()
	#var rx := ry.cross(Vector3.UP).normalized()
	#var rz := rx.cross(ry)

	floor_marker.global_transform.basis = Basis.looking_at(theWallNormal, Vector3.UP)#Basis(rx, ry, rz)
	
	#floor_marker.global_rotation = theWallNormal #???
	
	if(!checkFreeShape(free_space_shape, 1)):
		#print("FREE SPACE FAILED")
		
		return false
	
	var freeWall:float = checkFreeShapeSubdivided(must_be_filled_space, Vector3i(3, 2, 1), 1)
	if(freeWall > 0.0):
		#print(freeWall)
		return false
	var freeFloor:float = checkFreeShapeSubdivided(must_be_filled_space_2, Vector3i(3, 3, 1), 1)
	if(freeFloor > 0.0):
		return false
	return true

func getLeanTransform() -> Transform3D:
	return final_pos_marker.global_transform
