extends DollPart

var straponMat:ShaderMaterial

@onready var guide_path: Path3D = %GuidePath
@onready var penis_skeleton_modifier: PenisSkeletonModifier = %PenisSkeletonModifier
@onready var follow_spline_skeleton_modifier: FollowSplineSkeletonModifier = %FollowSplineSkeletonModifier
@onready var jiggleModifiers:Array[SkeletonModifier3D] = [
	$StraponBasic/StraponPenisRig/Skeleton3D/Wiggle1,
	$StraponBasic/StraponPenisRig/Skeleton3D/Wiggle2,
	$StraponBasic/StraponPenisRig/Skeleton3D/Wiggle3,
	$StraponBasic/StraponPenisRig/Skeleton3D/Wiggle4,
	$StraponBasic/StraponPenisRig/Skeleton3D/Wiggle5,
	$StraponBasic/StraponPenisRig/Skeleton3D/Wiggle6,
]
@onready var human_dildo: MeshInstance3D = $StraponBasic/StraponPenisRig/Skeleton3D/HumanDildo

@onready var strapon_harness: MeshInstance3D = $StraponHarness/rig/Skeleton3D/StraponHarness

func grabMaterials():
	straponMat = human_dildo.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(straponMat != null):
		if(_optionID == "color"):
			straponMat.set_shader_parameter("albedo", _value)
	#if(_optionID == "shifted"):
		#plain_panties.visible = !_value
		#plain_panties_shifted.visible = _value
		#triggerDollPartFlagsUpdate()
			
func applyCharOption(_optionID:String, _value:Variant):
	updateThicknessBody(_optionID)

func gatherPartFlags(_theFlags:Dictionary):
	#if(!getOptionValue("shifted", false)):
	_theFlags["HidePenis"] = true
	_theFlags["NormalVagina"] = true

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HidePanties") && _theFlags["HidePanties"]):
		visible = false
	else:
		visible = true
	#if(_theFlags.has("CrotchBulge") && _theFlags["CrotchBulge"]):
	#	setBlendshape("CrotchBulge", 1.0)
	#else:
	#	setBlendshape("CrotchBulge", 0.0)

var enableTween:Tween
func enableSplineModifier(doEn:bool, _time:float = 0.5):
	if(enableTween):
		enableTween.kill()
		enableTween = null
	enableTween = create_tween()
	enableTween.set_parallel(true)
	
	follow_spline_skeleton_modifier.active = true
	enableTween.tween_property(follow_spline_skeleton_modifier, "influence", 1.0 if doEn else 0.0, _time)
	for mod in jiggleModifiers:
		mod.active = true
		enableTween.tween_property(mod, "influence", 0.0 if doEn else 1.0, _time)
	enableTween.chain().tween_callback(doEnableSpline.bind(doEn))
	
func doEnableSpline(_isEn:bool):
	follow_spline_skeleton_modifier.active = _isEn
	for mod in jiggleModifiers:
		mod.active = !_isEn
	if(!_isEn):
		follow_spline_skeleton_modifier.holeNode = null
		follow_spline_skeleton_modifier.insideNode = null
		guide_path.holeNode = null
		guide_path.insideNode = null

func setPenisTargets(holeNode:Node3D, insideNode:Node3D):
	if(!holeNode || !insideNode):
		#follow_spline_skeleton_modifier.holeNode = null
		#follow_spline_skeleton_modifier.insideNode = null
		#guide_path.holeNode = null
		#guide_path.insideNode = null
		enableSplineModifier(false)
		#follow_spline_skeleton_modifier.active = false
		#for mod in jiggleModifiers:
		#	mod.active = true
		return
	follow_spline_skeleton_modifier.holeNode = holeNode
	follow_spline_skeleton_modifier.insideNode = insideNode
	guide_path.holeNode = holeNode
	guide_path.insideNode = insideNode
	enableSplineModifier(true)
	#for mod in jiggleModifiers:
	#	mod.active = false
	#follow_spline_skeleton_modifier.active = true

func supportsPenisGirth() -> bool:
	return true

func getPenisGirth() -> float:
	return 0.5
