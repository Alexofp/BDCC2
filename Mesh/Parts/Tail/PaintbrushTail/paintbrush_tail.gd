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

var tailMat:ShaderMaterial
@onready var paintbrush_tail: MeshInstance3D = %PaintbrushTail
@onready var tailSkeletonModifier: TailSkeletonModifier = %TailSkeletonModifier
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func grabMaterials():
	tailMat = paintbrush_tail.get_surface_override_material(0)

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "idleAnim"):
		updateTailAnimation()
	elif(_optionID == "thickness"):
		setBlendshape("Thickness", _value)
	elif(_optionID == "fullness"):
		setBlendshape("Fullness", _value)
	elif(_optionID == "wobbly"):
		setBlendshape("Wobbly", _value)
	#elif(_optionID == "width"):
	#	setBlendshape("Width", _value)
	elif(_optionID == "pattern"):
		applyColormaskPatternToMyMat(tailMat, _value)
	elif(_optionID == "tailLenMod"):
		if(tailSkeletonModifier):
			tailSkeletonModifier.lenModifier = _value

func applySkinTypeData(_skinType:int, _skinTypeData:SkinTypeData):
	if(tailMat == null):
		return
	
	tailMat.set_shader_parameter("albedo", _skinTypeData.color)

func updateTailAnimation():
	var theIdleAnim:int = getOptionValue("idleAnim", TAILANIM_WAG) if !getCachedPartFlag("TailSex", false) else TAILANIM_WRAPPEDAROUND
	
	var theFinalAnim := theIdleAnim
	if(TAIL_ANIMS.has(theFinalAnim)):
		animation_player.play(TAIL_ANIMS[theFinalAnim], 0.5)
	else:
		animation_player.play("TailRest", 0.5)

func applyPartFlags(_theFlags:Dictionary):
	updateTailAnimation()
