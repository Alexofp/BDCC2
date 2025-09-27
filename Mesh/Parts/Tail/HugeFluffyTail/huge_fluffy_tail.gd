extends DollPart

const TAILANIM_WAG = 0
const TAILANIM_WAGHIGH = 1
const TAILANIM_REST = 2
const TAILANIM_WRAPPEDAROUND = 3
const TAILANIM_HUG = 4
const TAILANIM_SPEAR = 5

const TAILTYPE_BAND_BOW = 0
const TAILTYPE_BAND = 1
const TAILTYPE_BOW = 2
const TAILTYPE_PLAIN = 3

const TAIL_ANIMS = {
	TAILANIM_WAG: "TailWag",
	TAILANIM_WAGHIGH: "TailWagHigh",
	TAILANIM_REST: "TailRest",
	TAILANIM_WRAPPEDAROUND: "TailWrappedAround",
	TAILANIM_HUG: "TailHug",
	TAILANIM_SPEAR: "TailTPose",
}

var tailMat:ShaderMaterial
var bowMat:ShaderMaterial
@onready var huge_fluffy_tail: MeshInstance3D = %HugeFluffyTail
@onready var tailSkeletonModifier: TailSkeletonModifier = %TailSkeletonModifier
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var bow: MeshInstance3D = %Bow
@onready var band: MeshInstance3D = %Band


func grabMaterials():
	tailMat = huge_fluffy_tail.get_surface_override_material(0)
	bowMat = bow.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "idleAnim"):
		if(TAIL_ANIMS.has(_value)):
			animation_player.play(TAIL_ANIMS[_value], 0.5)
		else:
			animation_player.play("TailRest", 0.5)
	elif(_optionID == "thickness"):
		setBlendshape("Thickness", _value)
	elif(_optionID == "taper"):
		setBlendshape("Tappered", _value)
	elif(_optionID == "tip"):
		setBlendshape("Tip", _value)
	elif(_optionID == "pattern"):
		applyColormaskPatternToMyMat(tailMat, _value)
	elif(_optionID == "tailLenMod"):
		if(tailSkeletonModifier):
			tailSkeletonModifier.lenModifier = _value
	elif(_optionID == "tailType"):
		if(_value in [TAILTYPE_PLAIN, TAILTYPE_BOW]):
			setBlendshape("NoBand", 1.0)
		else:
			setBlendshape("NoBand", 0.0)
		bow.visible = (_value in [TAILTYPE_BAND_BOW, TAILTYPE_BOW])
		band.visible = (_value in [TAILTYPE_BAND_BOW, TAILTYPE_BAND])
	elif(_optionID == "bowColor"):
		if(bowMat):
			bowMat.set_shader_parameter("albedo", _value)
	
func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(tailMat == null):
		return
	
	tailMat.set_shader_parameter("albedo", _skinTypeData.color)
	
