extends DollPart

var tailMat:MyMasterMaterial
@onready var feline_tail: MeshInstance3D = %FelineTail
@onready var fuzzyTail: MeshInstance3D = %FelineTailFuzz
@onready var lionTip: MeshInstance3D = %FelineTailLionTip
@onready var tailSkeletonModifier: TailSkeletonModifier = %TailSkeletonModifier
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func grabMaterials():
	tailMat = fuzzyTail.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "idleAnim"):
		animation_player.play(_value, 0.5)
	if(_optionID == "tailType"):
		if(fuzzyTail):
			fuzzyTail.visible = (_value == "fluffy")
		if(lionTip):
			lionTip.visible = (_value == "lion")
	if(_optionID == "thickness"):
		if(_value >= 0.0):
			setBlendshape("Thick", _value)
			setBlendshape("Lion", 0.0)
		else:
			setBlendshape("Thick", 0.0)
			setBlendshape("Lion", -_value)
	if(_optionID == "pattern"):
		applyColormaskPatternToMyMat(tailMat, _value)
	if(_optionID == "tailLenMod"):
		if(tailSkeletonModifier):
			tailSkeletonModifier.lenModifier = _value

func applySkinTypeData(_skinTypeData:SkinTypeData):
	if(tailMat == null):
		return
	
	tailMat.set_shader_parameter("albedo", _skinTypeData.color)
	
