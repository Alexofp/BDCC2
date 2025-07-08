extends DollPart

@onready var dragon_tail: MeshInstance3D = %DragonTail
@onready var ridges: MeshInstance3D = %Ridges
@onready var tail_fluff: MeshInstance3D = %TailFluff
@onready var under_fluff: MeshInstance3D = %UnderFluff
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var tailMat:MyMasterMaterial
@onready var tailSkeletonModifier: TailSkeletonModifier = %TailSkeletonModifier

func grabMaterials():
	tailMat = dragon_tail.get_surface_override_material(0)
	pass

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "idleAnim"):
		animation_player.play(_value, 0.5)
	if(_optionID == "underfluff"):
		under_fluff.visible = _value
	if(_optionID == "ridges"):
		ridges.visible = _value
	if(_optionID == "tipfluff"):
		tail_fluff.visible = _value
	if(_optionID == "thickness"):
		setBlendshape("Thick", _value)
	if(_optionID == "pattern"):
		applyColormaskPatternToMyMat(tailMat, _value)
	if(_optionID == "tailLenMod"):
		if(tailSkeletonModifier):
			tailSkeletonModifier.lenModifier = _value

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(tailMat == null):
		return
	
	tailMat.set_shader_parameter("albedo", _skinTypeData.color)
	
