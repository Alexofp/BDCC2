extends SkeletonModifier3D
class_name SkeletonHitModifier

@export var stiffness: float = 60.0         # rotational spring stiffness
@export var damping: float = 12.0            # rotational damping
@export var max_angle_deg: float = 55.0      # maximum angle deviation per bone (deg)
@export var falloff_radius: float = 0.6      # how far neighboring bones are affected (meters)
@export var impulse_scale: float = 1.0       # global scale for incoming impulses

# --- Struggle parameters ---
@export var struggle_enabled: bool = false
@export var struggle_min_interval: float = 0.2
@export var struggle_max_interval: float = 1.1
@export var struggle_min_strength: float = 0.8
@export var struggle_max_strength: float = 1.2
# optional exported list of bone names to bias struggles toward; empty = any bone
@export var struggle_target_bones: Array[String] = []

# Internal per-bone data
var bonesQuats: Array[Quaternion] = []
var bonesAngVal: Array[Vector3] = []
var bonesHitDelay: Array[float] = []

# Which bones are currently being processed
var activeBones: Dictionary[int, bool] = {}

var _skeleton_ref: Skeleton3D = null

# internal RNG and timers
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _struggle_timer: float = 0.0

func _enter_tree() -> void:
	_rng.randomize()

func _validate_bone_names() -> void:
	# Called by engine when entering tree or changing skeleton; (re)initialise per-bone data
	_init_bones()

func _skeleton_changed(_old_skel: Skeleton3D, new_skel: Skeleton3D) -> void:
	_skeleton_ref = new_skel
	_init_bones()

func _init_bones() -> void:
	_skeleton_ref = get_skeleton()
	if not _skeleton_ref:
		bonesQuats.clear()
		bonesAngVal.clear()
		bonesHitDelay.clear()
		activeBones.clear()
		return

	var count:int = _skeleton_ref.get_bone_count()
	bonesQuats.resize(count)
	bonesAngVal.resize(count)
	bonesHitDelay.resize(count)
	for i in range(count):
		bonesQuats[i] = Quaternion()
		bonesAngVal[i] = Vector3.ZERO
		bonesHitDelay[i] = 0.0
		if not activeBones.has(i):
			activeBones[i] = false

	_schedule_next_struggle()

func applyHit(bone_name: String, worldDir: Vector3, strength: float = 1.0, radius: float = -1.0) -> void:
	if !is_inside_tree():
		return
	_skeleton_ref = get_skeleton()
	if !_skeleton_ref:
		return
	var idx := _skeleton_ref.find_bone(bone_name)
	if(idx < 0):
		printerr("SkeletonHitModifier.applyHit: bone '" + bone_name + "' not found")
		return
	if radius <= 0.0:
		radius = falloff_radius

	worldDir = worldDir.normalized()
	_apply_impulse_to_index(idx, worldDir, strength, radius)

func _process_modification_with_delta(delta: float) -> void:
	if(!is_active()):
		return
	_skeleton_ref = get_skeleton()
	if(!_skeleton_ref):
		return

	# handle struggle timer and trigger random micro-hits
	if struggle_enabled:
		_struggle_timer -= delta
		if _struggle_timer <= 0.0:
			_perform_struggle_iteration()
			_schedule_next_struggle()

	var toRemoveFromActive: Array[int] = []
	for i in activeBones:
		if(bonesHitDelay[i] > 0.0):
			bonesHitDelay[i] -= delta
			continue
		
		# convert quaternion to axis-angle for spring calculation
		var axis_angle: Array = _get_axis_angle_safe(bonesQuats[i]) # [axis, angle]
		var axis: Vector3 = axis_angle[0]
		var angle: float = axis_angle[1]

		# rotational spring torque: -k * angle
		var torque: Vector3 = -stiffness * angle * axis
		var ang_acc: Vector3 = torque

		# integrate angular velocity (bone-local)
		bonesAngVal[i] += ang_acc * delta

		# damping
		bonesAngVal[i] = bonesAngVal[i] * exp(-damping * delta)

		# integrate quaternion from ang_vel
		var w: float = bonesAngVal[i].length()
		if w > 1e-7:
			var axis_av = bonesAngVal[i].normalized()
			var dtheta = w * delta
			var dq = Quaternion(axis_av, dtheta)
			bonesQuats[i] = dq * bonesQuats[i]

		# clamp overall angle
		var aa := _get_axis_angle_safe(bonesQuats[i])
		var new_angle = aa[1]
		var max_rad = deg_to_rad(max_angle_deg)
		if new_angle > max_rad:
			var axis_q: Vector3 = aa[0]
			bonesQuats[i] = Quaternion(axis_q, max_rad)

		# Turning off bone processing for ones that have finished animating
		if bonesAngVal[i].length() < 0.01 and _quat_is_identity(bonesQuats[i]):
			#activeBones.erase(i) #Doesn't work because we're in the middle of iterating over the dictonary
			toRemoveFromActive.append(i)
			continue

		# Apply to skeleton: read current local bone pose and multiply a delta rotation in local space
		if(!_quat_is_identity(bonesQuats[i])):
			var cur_pose: Transform3D = _skeleton_ref.get_bone_pose(i)
			var delta_basis := Basis(bonesQuats[i]) # rotation in bone-local space
			var new_local := Transform3D(delta_basis, Vector3.ZERO) * cur_pose
			# Write full pose — Skeleton3D will blend using this modifier's influence property
			_skeleton_ref.set_bone_pose(i, new_local)
	
	for i in toRemoveFromActive:
		activeBones.erase(i)
	
func _schedule_next_struggle() -> void:
	if(!struggle_enabled):
		_struggle_timer = INF
		return
	_struggle_timer = _rng.randf_range(struggle_min_interval, struggle_max_interval)

func _perform_struggle_iteration() -> void:
	if(!_skeleton_ref):
		return
	var hits:int = _rng.randi_range(2, 4)
	for h in range(hits):
		var strength:float = _rng.randf_range(struggle_min_strength, struggle_max_strength)

		var bone_idx:int = _choose_random_bone_index()
		if(bone_idx < 0):
			continue

		var dir := Vector3(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)).normalized()
		_apply_impulse_to_index(bone_idx, dir, strength)

func _choose_random_bone_index() -> int:
	if(!_skeleton_ref):
		return -1
	var count:int = _skeleton_ref.get_bone_count()
	if(count <= 0):
		return -1
	# if user provided target bone names, pick one of them (if available)
	if(struggle_target_bones.size() > 0):
		for _i in range(4):
			var theName:String = struggle_target_bones[_rng.randi_range(0, struggle_target_bones.size() - 1)]
			var idx:int = _skeleton_ref.find_bone(theName)
			if(idx >= 0):
				return idx
	# fallback: pick a bone biased toward upper-body: choose from first ~40% bones if count>4
	#if count > 4:
		#var upper_count = max(1, int(count * 0.45))
		#if _rng.randf() < 0.8:
			#return _rng.randi_range(0, upper_count - 1)
	# fully random fallback
	return _rng.randi_range(0, count - 1)

func _apply_impulse_to_index(idx: int, worldDir: Vector3, strength: float, radius: float = -1.0) -> void:
	if(!_skeleton_ref):
		return
	if(idx < 0 || idx >= _skeleton_ref.get_bone_count()):
		return
	if(radius <= 0.0):
		radius = falloff_radius
	var target_global := _skeleton_ref.get_bone_global_pose(idx)
	for i in range(_skeleton_ref.get_bone_count()):
		var b_global := _skeleton_ref.get_bone_global_pose(i)
		var d: float = b_global.origin.distance_to(target_global.origin)
		var fall: float = clamp(1.0 - (d / radius), 0.0, 1.0)
		if(fall <= 0.0):
			continue

		var bone_basis := b_global.basis
		var bone_forward := bone_basis.z
		var axis_global := worldDir.cross(bone_forward)
		if axis_global.length_squared() < 1e-6:
			axis_global = bone_basis.x
		axis_global = axis_global.normalized()
		var axis_local := bone_basis.inverse() * axis_global

		var added := axis_local * (strength * impulse_scale * fall) * _rng.randf_range(0.8, 1.0)
		if(bonesHitDelay[i] <= 0.0 && bonesAngVal[i].length_squared() < 0.001):
			bonesHitDelay[i] = _rng.randf_range(0.0, 0.1) # Delay some of the impact to make it look better
		bonesAngVal[i] += added
		activeBones[i] = true

# --- helpers ---
const QUAT_IDENTITY_THRESHOLD = 0.002

func _quat_is_identity(q: Quaternion) -> bool:
	return abs(q.x) < QUAT_IDENTITY_THRESHOLD and abs(q.y) < QUAT_IDENTITY_THRESHOLD and abs(q.z) < QUAT_IDENTITY_THRESHOLD and abs(q.w - 1.0) < QUAT_IDENTITY_THRESHOLD

func _get_axis_angle_safe(q: Quaternion) -> Array:
	var qw: float = clamp(q.w, -1.0, 1.0)
	var angle := 2.0 * acos(qw)
	var s := sqrt(max(0.0, 1.0 - qw * qw))
	if s < 0.0001:
		return [Vector3(1,0,0), 0.0]
	else:
		var axis: Vector3 = Vector3(q.x, q.y, q.z) / s
		return [axis.normalized(), angle]

func startStruggle(_strengthMin:float, _strengthMax:float, _timeMin:float, _timeMax:float, _bones:Array[String] = []) -> void:
	struggle_min_strength = _strengthMin
	struggle_max_strength = _strengthMax
	struggle_min_interval = _timeMin
	struggle_max_interval = _timeMax
	struggle_target_bones = _bones
	struggle_enabled = true
	_schedule_next_struggle()

func stopStruggle() -> void:
	struggle_enabled = false
	_struggle_timer = INF

func isStruggling() -> bool:
	return struggle_enabled
