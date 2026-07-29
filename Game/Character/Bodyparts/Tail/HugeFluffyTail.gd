extends BodypartTailBase

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

var tailType:int = TAILTYPE_BAND_BOW
var thickness:float = 0.0
var taper:float = 0.0
var tip:float = 0.0
var tailLenMod:float = 1.0
var idleAnim:int = TAILANIM_WAG
var bowColor = Color("ff65ff")

var pattern:Dictionary = {
	id = "",
	r = Color(0.7, 0.7, 0.7),
	g = Color(0.5, 0.5, 0.5),
	b = Color(0.3, 0.3, 0.3),
}

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	bowColor = _gen.colors.hairBow
	tailType = RNG.pick([
		TAILTYPE_BAND_BOW,
		TAILTYPE_BAND,
		TAILTYPE_BOW,
		TAILTYPE_PLAIN
	])
	thickness = randf_range(-0.5, 0.5)

func _init():
	super._init()
	id = "HugeFluffyTail"

func getName() -> String:
	return "Huge Fluffy tail"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Tail/HugeFluffyTail/huge_fluffy_tail.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.Fur: true,
	}

func getOptions() -> Dictionary:
	var theOptions:Dictionary = super.getOptions()
	theOptions["idleAnim"] = {
			name = "Idle animation",
			type = "selector",
			values = [
				[TAILANIM_WAG, "Wag"],
				[TAILANIM_WAGHIGH, "Wag high"],
				[TAILANIM_REST, "Rest"],
				[TAILANIM_WRAPPEDAROUND, "Wrapped"],
				[TAILANIM_HUG, "Hug"],
				[TAILANIM_SPEAR, "Spear"],
			],
			editors = [EDITOR_PART, EDITOR_INTERACT],
		}
	theOptions["tailLenMod"] = {
			name = "Length",
			type = "slider",
			min = 0.6,
			max = 1.5,
			editors = [EDITOR_PART],
		}
	#theOptions["underfluff"] = {
			#name = "Under fluff",
			#type = "bool",
			#editors = [EDITOR_PART],
		#}
	#theOptions["ridges"] = {
			#name = "Ridges",
			#type = "bool",
			#editors = [EDITOR_PART],
		#}
	#theOptions["tipfluff"] = {
			#name = "Tip fluff",
			#type = "bool",
			#editors = [EDITOR_PART],
		#}
	theOptions["tailType"] = {
			name = "Tail type",
			type = "selector",
			values = [
				[TAILTYPE_BAND_BOW, "Band+Bow"],
				[TAILTYPE_BAND, "Just band"],
				[TAILTYPE_BOW, "Just bow"],
				[TAILTYPE_PLAIN, "Plain"],
			],
			editors = [EDITOR_PART],
		}
	theOptions["bowColor"] = {
			name = "Bow color",
			type = "color",
			editors = [EDITOR_PART],
		}
	theOptions["thickness"] = {
			name = "Thickness",
			type = "slider",
			min = -1.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["taper"] = {
			name = "Taper",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["tip"] = {
			name = "Tip",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.TailPattern,
			texSubType = "HugeFluffyTail",
			editors = [EDITOR_PART],
		}

		
	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Tail/HugeFluffyTail/Textures/Layers/HugeFluffyTailLayersMany.gd",
	]
