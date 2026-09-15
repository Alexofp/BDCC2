extends DollPart

@onready var balls: MeshInstance3D = $CaninePenisRig/Skeleton3D/Balls
@onready var shaft: MeshInstance3D = $CaninePenisRig/Skeleton3D/Shaft

var ballsMat:ShaderMaterial
var shaftMat:ShaderMaterial
#@export var nodeToScale:Node3D
@export var furTuft:MeshInstance3D
var tuftMat:ShaderMaterial
#@export var penisModifier:PenisSkeletonModifier

@onready var penis_handler: PenisHandler = %PenisHandler

func grabMaterials():
	shaftMat = shaft.get_surface_override_material(0)
	ballsMat = balls.get_surface_override_material(0)
	tuftMat = furTuft.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(penis_handler.applyOption(_optionID, _value)):
		return
	
	#if(_optionID == "penisScale"):
	#	penis_handler.setPenisRootScale(_value)
	if(_optionID == "furTuft"):
		if(furTuft):
			furTuft.visible = _value
	if(_optionID == "furTuftColor"):
		if(tuftMat):
			tuftMat.set_shader_parameter("albedo", _value)
	#if(_optionID == "penisLenMod"):
		#if(penisModifier):
			#penisModifier.lenModifier = _value
	#if(_optionID == "penBallsDrop"):
		#if(penisModifier):
			#penisModifier.ballsDrop = _value
	#if(_optionID == "penBallsScale"):
		#if(penisModifier):
			#penisModifier.ballsScale = _value
	if(_optionID == "shaftColor"):
		if(shaftMat):
			shaftMat.set_shader_parameter("albedo", _value)
	if(_optionID == "pattern"):
		if(shaftMat):
			applyColormaskPatternToMyMat(shaftMat, _value)

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(ballsMat == null):
		return
	
	ballsMat.set_shader_parameter("albedo", _skinTypeData.color)
	
func getPenisHandler() -> PenisHandlerBase:
	return penis_handler

func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["CrotchBulge"] = true

var savedCageShapekey:String = ""

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HidePenis") && _theFlags["HidePenis"]):
		visible = false
	else:
		visible = true
	
	if(_theFlags.has("SmallerPenisBulge") && _theFlags["SmallerPenisBulge"]):
		setBlendshape("TaintBulgeLess", 1.0)
	else:
		setBlendshape("TaintBulgeLess", 0.0)

	if(!savedCageShapekey.is_empty()):
		setBlendshape(savedCageShapekey, 0.0)
		setBlendshape("Caged", 0.0)
		savedCageShapekey = ""
	if(_theFlags.has("CageType") && _theFlags["CageType"]):
		savedCageShapekey = _theFlags["CageType"]
		setBlendshape(savedCageShapekey, 1.0)
		setBlendshape("Caged", 1.0)
		penis_handler.setCaged(true)
	else:
		penis_handler.setCaged(false)

func supportsPenisGirth() -> bool:
	return true

# Used to stroking sex anims
func getPenisGirth() -> float:
	#return remap(nodeToScale.scale.x, 0.0, 0.8, 0.0, 1.0)
	#return remap(penis_handler.getPenisRootScale(), 0.0, 0.8, 0.0, 1.0)
	return penis_handler.getPenisRootScale()*1.2
