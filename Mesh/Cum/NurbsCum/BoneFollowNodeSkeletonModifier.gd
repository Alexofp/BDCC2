@tool
extends SkeletonModifier3D
class_name BoneFollowNodeSkeletonModifier

@export var bodies:Array[Node3D] = []
@export var randomScales:Array = []

func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for the safety.
	var bodiesSize:int = bodies.size()
	
	var boneCount:int = skeleton.get_bone_count()
	var newTFs:Array[Transform3D] = []
	for _i in range(boneCount):
		#var bone_idx: int = _i
		if(_i >= bodiesSize):
			continue
		var theBody:Node3D = bodies[_i]
		if(!theBody.is_inside_tree()):
			return
		
		newTFs.append(skeleton.global_transform.inverse()*theBody.global_transform)
	
	for _i in range(boneCount):
		#var bone_idx: int = _i
		if(_i >= bodiesSize):
			continue
		#var theBody:Node3D = bodies[_i]
		var theTF:Transform3D = newTFs[_i]
		#theTF = theTF.scaled(Vector3(1.0, 1.0, 1.0)*randomScales[_i])
		if(_i == 0):
			theTF = _y_look_at(theTF, bodies[_i+1].position)
		elif(_i == (bodiesSize-1)):
			theTF = _y_look_away(theTF, bodies[_i-1].position)
		elif(_i > 0 && _i < (bodiesSize-1)):
			theTF = _y_look_away(theTF, bodies[_i-1].position)
			theTF = _y_look_at_int(theTF, bodies[_i+1].position)
		skeleton.set_bone_global_pose(_i, theTF)
		skeleton.set_bone_pose_scale(_i, Vector3(1.0, 1.0, 1.0)*randomScales[_i])

func _y_look_away(from: Transform3D, target: Vector3) -> Transform3D:
	var t_v: Vector3 = from.origin - target
	if(t_v.length_squared() == 0.0):
		return from
	var v_y: Vector3 = t_v.normalized()
	var v_z: Vector3 = from.basis.x.cross(v_y)
	v_z = v_z.normalized()
	var v_x: Vector3 = v_y.cross(v_z)
	from.basis = Basis(v_x, v_y, v_z)
	return from

func _y_look_at(from: Transform3D, target: Vector3) -> Transform3D:
	var t_v: Vector3 = target - from.origin
	if(t_v.length_squared() == 0.0):
		return from
	var v_y: Vector3 = t_v.normalized()
	var v_z: Vector3 = from.basis.x.cross(v_y)
	v_z = v_z.normalized()
	var v_x: Vector3 = v_y.cross(v_z)
	from.basis = Basis(v_x, v_y, v_z)
	return from

func _y_look_at_int(from: Transform3D, target: Vector3, interpolation:float=0.5) -> Transform3D:
	var t_v: Vector3 = target - from.origin
	if(t_v.length_squared() == 0.0):
		return from
	var v_y: Vector3 = t_v.normalized()
	var v_z: Vector3 = from.basis.x.cross(v_y)
	v_z = v_z.normalized()
	var v_x: Vector3 = v_y.cross(v_z)
	from.basis = from.basis.slerp(Basis(v_x, v_y, v_z), interpolation)
	return from
