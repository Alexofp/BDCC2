extends BodypartBase
class_name BodypartBodyBase

var legType:String = "planti" # planti digi
var bodyLayers:Array = []
var breasts:float = 1.0
var nippleShape:float = 0.0
var breastsCleavage:float = 0.0
var nippleColor:Color = Color("f58c8c")

var claws:float = 0.0
var clawsColor:Color = Color("855a5a")
var toeClawColor:Color = Color("855a5a")
var handPads:bool = false
var handPadsColor:Color = Color("a6a6a6")
var hindPawPadColor:Color = Color("a6a6a6")

func getBodypartType() -> int:
	return BodypartType.Body

func getOptions() -> Dictionary:
	return {
		"breasts": {
			name = "Breast size",
			type = "slider",
			min = 0.0,
			max = 3.0,
			editors = [EDITOR_PART],
		},
		"breastsCleavage": {
			name = "Breast cleavage",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		},
		"nippleShape": {
			name = "Nipples shape",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		},
		"nippleColor": {
			name = "Nipples color",
			type = "color",
			editors = [EDITOR_PART],
		},
		"legType": {
			name = "Legs",
			type = "selector",
			values = [
				["planti", "Plantigrade"],
				["digi", "Digitigrade"],
			],
			editors = [EDITOR_PART],
		},
		"bodyLayers": {
			name = "Layers",
			type = "texVarLayerList",
			texType = TextureVariantType.BodyLayer,
			texSubType = "def",
			editors = [EDITOR_SKIN],
		},
		"handPads": {
			name = "Hand pads",
			type = "bool",
			editors = [EDITOR_PART],
		},
		"handPadsColor": {
			name = "Hand pads color",
			type = "color",
			editors = [EDITOR_PART],
		},
		"claws": {
			name = "Claws",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		},
		"clawsColor": {
			name = "Claw/nail color",
			type = "color",
			editors = [EDITOR_PART],
		},
		"toeClawColor": {
			name = "Toe claw/tail color",
			type = "color",
			editors = [EDITOR_PART],
		},
		"hindPawPadColor": {
			name = "Digi-leg pawpad color",
			type = "color",
			editors = [EDITOR_PART],
		},
	}

#func getOptionValue(_optionID:String) -> Variant:
	#if(_optionID == "thickness"):
		#return thickness
	#
	#return super.getOptionValue(_optionID)
#
#func applyOption(_optionID:String, _value:Variant):
	#if(_optionID == "thickness"):
		#thickness = _value
		#return
		#
	#super.applyOption(_optionID, _value)
