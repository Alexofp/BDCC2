extends BodypartTailBase

const TAIL_FLUFFY = 0
const TAIL_SMOOTH = 1
const TAIL_LIONTIP = 2

const TAILANIM_WAG = 0
const TAILANIM_WAGHIGH = 1
const TAILANIM_REST = 2
const TAILANIM_WRAPPEDAROUND = 3
const TAILANIM_HUG = 4
const TAILANIM_SPEAR = 5

var tailType:int = TAIL_FLUFFY
var thickness:float = 0.0
var tailLenMod:float = 1.0
var idleAnim:int = TAILANIM_WAG

var pattern:Dictionary = {
	id = "",
	r = Color(0.7, 0.7, 0.7),
	g = Color(0.5, 0.5, 0.5),
	b = Color(0.3, 0.3, 0.3),
}

func _init():
	super._init()
	id = "LongTail"

func getName() -> String:
	return "Long tail"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Tail/LongTail/long_tail.tscn"

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
			min = 0.9,
			max = 1.5,
			editors = [EDITOR_PART],
		}
	theOptions["tailType"] = {
			name = "Tail type",
			type = "selector",
			values = [
				[TAIL_SMOOTH, "Smooth"],
				[TAIL_FLUFFY, "Fluffy"],
				[TAIL_LIONTIP, "Lion tip"],
			],
			editors = [EDITOR_PART],
		}
	theOptions["thickness"] = {
			name = "Thickness",
			type = "slider",
			min = -1.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.TailPattern,
			texSubType = "LongTail",
			editors = [EDITOR_PART],
		}

		
	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Tail/LongTail/Textures/Layers/LongTailLayersMany.gd",
	]
