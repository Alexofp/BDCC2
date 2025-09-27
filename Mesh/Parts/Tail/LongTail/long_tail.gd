extends DollPart

const TAIL_FLUFFY = 0
const TAIL_SMOOTH = 1
const TAIL_LIONTIP = 2

const TAILANIM_WAG = 0
const TAILANIM_WAGHIGH = 1
const TAILANIM_REST = 2
const TAILANIM_WRAPPEDAROUND = 3
const TAILANIM_HUG = 4
const TAILANIM_SPEAR = 5

const TAIL_ANIMS = {
	TAILANIM_WAG: "TailWag",
	TAILANIM_WAGHIGH: "TailWagHigh",
	TAILANIM_REST: "TailRest",
	TAILANIM_WRAPPEDAROUND: "TailWrappedAround",
	TAILANIM_HUG: "TailHug",
	TAILANIM_SPEAR: "TailTPose",
}

var tailMat:ShaderMaterial
@onready var feline_tail: MeshInstance3D = %FelineTail
@onready var fuzzyTail: MeshInstance3D = %FelineTailFuzz
@onready var lionTip: MeshInstance3D = %FelineTailLionTip
@onready var tailSkeletonModifier: TailSkeletonModifier = %TailSkeletonModifier
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func grabMaterials():
	tailMat = fuzzyTail.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "idleAnim"):
		if(TAIL_ANIMS.has(_value)):
			animation_player.play(TAIL_ANIMS[_value], 0.5)
		else:
			animation_player.play("TailRest", 0.5)
	if(_optionID == "tailType"):
		if(fuzzyTail):
			fuzzyTail.visible = (_value == TAIL_FLUFFY)
		if(lionTip):
			lionTip.visible = (_value == TAIL_LIONTIP)
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

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(tailMat == null):
		return
	
	tailMat.set_shader_parameter("albedo", _skinTypeData.color)
	
