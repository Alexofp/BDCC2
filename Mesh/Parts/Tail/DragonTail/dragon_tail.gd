extends DollPart

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

@onready var dragon_tail: MeshInstance3D = %DragonTail
@onready var ridges: MeshInstance3D = %Ridges
@onready var tail_fluff: MeshInstance3D = %TailFluff
@onready var under_fluff: MeshInstance3D = %UnderFluff
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var tailMat:ShaderMaterial
@onready var tailSkeletonModifier: TailSkeletonModifier = %TailSkeletonModifier

func grabMaterials():
	tailMat = dragon_tail.get_surface_override_material(0)
	pass

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "idleAnim"):
		if(TAIL_ANIMS.has(_value)):
			animation_player.play(TAIL_ANIMS[_value], 0.5)
		else:
			animation_player.play("TailRest", 0.5)
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

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(tailMat == null):
		return
	
	tailMat.set_shader_parameter("albedo", _skinTypeData.color)
	
