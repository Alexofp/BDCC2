extends BodypartTailBase

const TAILANIM_WAG = 0
const TAILANIM_WAGHIGH = 1
const TAILANIM_REST = 2
const TAILANIM_WRAPPEDAROUND = 3
const TAILANIM_HUG = 4
const TAILANIM_SPEAR = 5

#var tailType:String = "fluffy"
var thickness:float = 0.0
var fullness:float = 0.0
var wobbly:float = 0.0
#var width:float = 0.0
var tailLenMod:float = 1.0
#var underfluff:bool = true
#var ridges:bool = true
#var tipfluff:bool = true
var idleAnim:int = TAILANIM_WAG

var pattern:Dictionary = {
	id = "",
	r = Color(0.7, 0.7, 0.7),
	g = Color(0.5, 0.5, 0.5),
	b = Color(0.3, 0.3, 0.3),
}

func _init():
	super._init()
	id = "PaintbrushTail"

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	
	thickness = randf_range(-0.2, 1.0)
	fullness = randf_range(0.0, 1.0)
	wobbly = randf_range(0.0, 1.0)
	pickPattern(pattern, _gen, TextureVariantType.TailPattern, "PaintbrushTail")

func getName() -> String:
	return "Paintbrush tail"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Tail/PaintbrushTail/paintbrush_tail.tscn"

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
	#theOptions["tailType"] = {
			#name = "Tail type",
			#type = "selector",
			#values = [
				#["smooth", "Smooth"],
				#["fluffy", "Fluffy"],
				#["lion", "Lion tip"],
			#],
			#editors = [EDITOR_PART],
		#}
	theOptions["thickness"] = {
			name = "Thickness",
			type = "slider",
			min = -0.5,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["fullness"] = {
			name = "Fullness",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["wobbly"] = {
			name = "Wobbly",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	#theOptions["width"] = {
			#name = "Width",
			#type = "slider",
			#min = 0.0,
			#max = 1.0,
			#editors = [EDITOR_PART],
		#}
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.TailPattern,
			texSubType = "PaintbrushTail",
			editors = [EDITOR_PART],
		}

		
	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Tail/PaintbrushTail/Textures/Layers/PaintbrushTailLayersMany.gd",
	]
