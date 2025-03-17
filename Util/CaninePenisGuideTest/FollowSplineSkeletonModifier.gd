@tool
extends SkeletonModifier3D
class_name FollowSplineSkeletonModifier

@export_enum(" ") var bone: String
@export var chainLength:int = 1
@export var targetPath:Path3D

@export var thicknessCurve:Curve
@export var holeNode:Node3D

var thicknessAtHole:float = 0.0
var howDeepTip:float = 0.0

func _validate_property(property: Dictionary) -> void:
	if property.name == "bone":
		var skeleton: Skeleton3D = get_skeleton()
		if skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()

#func processHole():
	#if(!holeNode):
		#return
	#var skeleton: Skeleton3D = get_skeleton()
	#if !skeleton || !targetPath:
		#return
	#var curve := targetPath.curve
	
			
#func _process(_delta: float) -> void:
#	processHole()

func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton || !targetPath || !holeNode:
		return
	if(!is_inside_tree()):
		return
	var curve := targetPath.curve
	var startBoneIDx: int = skeleton.find_bone(bone)
	if(startBoneIDx < 0):
		return
	var affectedBones:Array = [startBoneIDx]
	var boneDistances:Array = [0.1]
	var boneIndx:int = startBoneIDx
	for _i in range(chainLength-1):
		var childPos:Vector3 = (skeleton.get_bone_global_pose(boneIndx).origin)
		boneIndx = skeleton.get_bone_parent(boneIndx)
		if(boneIndx >= 0):
			var parentPos:Vector3 = (skeleton.get_bone_global_pose(boneIndx).origin)
			#if(_i < (chainLength-1)):
			affectedBones.append(boneIndx)
			boneDistances.append(parentPos.distance_to(childPos))
	#boneDistances.append(0.0)
	
	affectedBones.reverse()
	boneDistances.reverse()
	
	var startOffset:float = 0
	var curveBakenLen:float = curve.get_baked_length()
	#print(curveBakenLen)
	
	var firstBoneIndx:int = affectedBones[0]
	startOffset += curve.get_closest_offset(targetPath.to_local(skeleton.to_global(skeleton.get_bone_global_pose(firstBoneIndx).origin)))
	
	# Hole stuff
	var firstBoneOffsetOnCurve:float = 0.0
	var lastBoneOffsetOnCurve:float = 0.0
	var holeOffsetOnCurve:float = curve.get_closest_offset(targetPath.to_local(holeNode.to_global(Vector3(0.0, 0.0, 0.0))))
	
	#print(boneDistances)
	var _i:int = 0
	for bone_idx in affectedBones:
		var pose := skeleton.get_bone_global_pose(bone_idx)
		var globalPose := skeleton.global_transform * pose
		
		var localPosToCurve:Vector3 = targetPath.to_local(globalPose.origin)
		
		var closestPointLocalToCurve:Vector3 = curve.sample_baked(startOffset, false)

		globalPose.origin = targetPath.to_global(closestPointLocalToCurve)
		
		#globalPose.origin = targetPath.to_global(targetPath.curve.get_point_position(1))
		pose = skeleton.global_transform.affine_inverse() * globalPose
		
		var curOffset:float = min(startOffset, curveBakenLen)
		var nextOffset:float = min(startOffset+boneDistances[_i], curveBakenLen)
		if(curOffset == nextOffset):
			pass
		else:
		#if((_i+1) < affectedBones.size()):
			var nextPointPosLocalToCurve:Vector3 = curve.sample_baked(startOffset+boneDistances[_i])

			pose = _y_look_at(pose, skeleton.to_local(targetPath.to_global(nextPointPosLocalToCurve)))
			
		
		skeleton.set_bone_global_pose(bone_idx, pose)
		startOffset += boneDistances[_i]
		
		
		#var pose := skeleton.get_bone_global_pose(bone_idx)
		#var globalPose := skeleton.global_transform * pose
		#var localPosToCurve:Vector3 = targetPath.to_local(globalPose.origin)
		var theOffsetOnCurve:float = curve.get_closest_offset(localPosToCurve)
		
		if(_i == 0):
			firstBoneOffsetOnCurve = theOffsetOnCurve
		elif(_i == affectedBones.size()-1):
			lastBoneOffsetOnCurve = theOffsetOnCurve
		
		_i += 1




	
	#for bone_idx in affectedBones:

	#print("BEFORE: ",closestIndxBefore," ",closestOffsetBefore)
	#print("AFTER: ",closestIndxAfter," ",closestOffsetAfter)
	
	lastBoneOffsetOnCurve += 0.03
	thicknessAtHole = 0.0
	howDeepTip = 0.0
	if(holeOffsetOnCurve >= firstBoneOffsetOnCurve && holeOffsetOnCurve <= lastBoneOffsetOnCurve):
		var factorOpen:float = clamp(1.0-(holeOffsetOnCurve-firstBoneOffsetOnCurve)/(lastBoneOffsetOnCurve-firstBoneOffsetOnCurve), 0.0, 1.0)
		howDeepTip = factorOpen
		#print(factorOpen)
		
		if(thicknessCurve):
			var theThickness:float = thicknessCurve.sample_baked(factorOpen)
			#print(theThickness)
			thicknessAtHole = theThickness * global_basis.get_scale().x
			if(holeNode is DollOpenableHole):
				holeNode.setRawOpenValue(thicknessAtHole)
				holeNode.setRawHowDeepTip(howDeepTip)
		#print(holeOffsetOnCurve)
		#print("BEFORE: ",firstBoneOffsetOnCurve, " AFTER: ",lastBoneOffsetOnCurve)

func getHoleOpenValue() -> float:
	return thicknessAtHole

func getHowDeepTipValue() -> float:
	return howDeepTip

func _y_look_at(from: Transform3D, target: Vector3) -> Transform3D:
	var t_v: Vector3 = target - from.origin
	var v_y: Vector3 = t_v.normalized()
	var v_z: Vector3 = from.basis.x.cross(v_y)
	v_z = v_z.normalized()
	var v_x: Vector3 = v_y.cross(v_z)
	from.basis = Basis(v_x, v_y, v_z)
	#from.basis = from.basis.orthonormalized()
	return from
