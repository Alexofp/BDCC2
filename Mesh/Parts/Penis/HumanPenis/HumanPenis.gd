extends DollPart

@onready var human_penis: MeshInstance3D = %HumanPenis

var shaftMat:ShaderMaterial
var tuftMat:ShaderMaterial
var pubesMat:ShaderMaterial
@onready var penis_handler: PenisHandler = %PenisHandler
@onready var fluff: MeshInstance3D = $HumanPenisRig/Skeleton3D/Fluff
@onready var pubes: MeshInstance3D = %Pubes
@onready var pubes_001: MeshInstance3D = %Pubes_001

func grabMaterials():
	shaftMat = human_penis.get_surface_override_material(0)
	tuftMat = fluff.get_surface_override_material(0)
	pubesMat = pubes.get_surface_override_material(0)

func updatePubesVis():
	var thePubes:int = getOptionValue("pubes", 0)
	if(fluff):
		fluff.visible = (thePubes == 2)
	
	var _isMasc:bool = getCachedPartFlag("MascCrotch", false)
	if(pubes):
		pubes.visible = ((thePubes == 1) && !_isMasc)
	if(pubes_001):
		pubes_001.visible = ((thePubes == 1) && _isMasc)

func applyOption(_optionID:String, _value:Variant):
	if(penis_handler.applyOption(_optionID, _value)):
		return
	
	if(_optionID == "pubes"):
		updatePubesVis()
	if(_optionID == "pubesColor"):
		if(tuftMat):
			tuftMat.set_shader_parameter("albedo", _value)
		if(pubesMat):
			pubesMat.set_shader_parameter("albedo", _value)
	#if(_optionID == "shaftColor"):
		#if(shaftMat):
			#shaftMat.set_shader_parameter("albedo", _value)
	if(_optionID == "pattern"):
		if(shaftMat):
			applyColormaskPatternToMyMat(shaftMat, _value)

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(shaftMat == null):
		return
	
	shaftMat.set_shader_parameter("albedo", _skinTypeData.color)
	pass
	
func getPenisHandler() -> PenisHandlerBase:
	return penis_handler

func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["CrotchBulge"] = true

var savedCageShapekey:String = ""

func applyPartFlags(_theFlags:Dictionary):
	updatePubesVis()
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

func getPenisGirth() -> float:
	#return remap(nodeToScale.scale.x, 0.0, 0.8, 0.0, 1.0)
	return penis_handler.getPenisRootScale()
