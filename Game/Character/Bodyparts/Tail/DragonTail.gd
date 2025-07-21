extends BodypartTailBase

#var tailType:String = "fluffy"
var thickness:float = 0.0
var tailLenMod:float = 1.0
var underfluff:bool = true
var ridges:bool = true
var tipfluff:bool = true
var idleAnim:String = "TailWag"

var pattern:Dictionary = {
	pattern = "DragonTail_Default",
	colorR = Color(0.7, 0.7, 0.7),
	colorG = Color(0.5, 0.5, 0.5),
	colorB = Color(0.3, 0.3, 0.3),
}

func _init():
	super._init()
	id = "DragonTail"

func getName() -> String:
	return "Dragon tail"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Tail/DragonTail/dragon_tail.tscn"

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
				["TailWag", "Wag"],
				["TailWagHigh", "Wag high"],
				["TailRest", "Rest"],
				["TailWrappedAround", "Wrapped"],
				["TailHug", "Hug"],
				["TailTPose", "Spear"],
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
	theOptions["underfluff"] = {
			name = "Under fluff",
			type = "bool",
			editors = [EDITOR_PART],
		}
	theOptions["ridges"] = {
			name = "Ridges",
			type = "bool",
			editors = [EDITOR_PART],
		}
	theOptions["tipfluff"] = {
			name = "Tip fluff",
			type = "bool",
			editors = [EDITOR_PART],
		}
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
			min = -1.0,
			max = 1.0,
			editors = [EDITOR_PART],
		}
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.TailPattern,
			texSubType = "DragonTail",
			editors = [EDITOR_SKIN],
		}

		
	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Tail/DragonTail/Textures/Layers/DragonTailLayersMany.gd",
	]
