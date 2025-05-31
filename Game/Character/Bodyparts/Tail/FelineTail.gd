extends BodypartTailBase

var tailType:String = "fluffy"
var thickness:float = 0.0
var tailLenMod:float = 1.0

var pattern:Dictionary = {
	pattern = "FelineTail_Default",
	colorR = Color(0.7, 0.7, 0.7),
	colorG = Color(0.5, 0.5, 0.5),
	colorB = Color(0.3, 0.3, 0.3),
}

func _init():
	id = "FelineTail"

func getName() -> String:
	return "Feline tail"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Tail/FelineTail/feline_tail.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.Fur: true,
	}

func getOptions() -> Dictionary:
	var theOptions:Dictionary = super.getOptions()
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
				["smooth", "Smooth"],
				["fluffy", "Fluffy"],
				["lion", "Lion tip"],
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
			texSubType = "FelineTail",
			editors = [EDITOR_SKIN],
		}

		
	return theOptions

func getTextureVariantsPaths() -> Array:
	return [
		"res://Mesh/Parts/Tail/FelineTail/Textures/Layers/FelineTailLayersMany.gd",
	]
