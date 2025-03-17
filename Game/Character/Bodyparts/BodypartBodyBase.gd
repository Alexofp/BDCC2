extends BodypartBase
class_name BodypartBodyBase

var thickness:float = 0.5
var legType:String = "planti" # planti digi
var bodyLayers:Array = []

func getBodypartType() -> String:
	return BodypartType.Body

func getOptions() -> Dictionary:
	return {
		"thickness": {
			name = "Thickness",
			type = "slider",
			min = 0.0,
			max = 1.0,
			delayUpdate = true,
			editors = ["part"],
		},
		"legType": {
			name = "Legs",
			type = "selector",
			values = [
				["planti", "Plantigrade"],
				["digi", "Digitigrade"],
			],
			editors = ["part"],
		},
		"bodyLayers": {
			name = "Layers",
			type = "texVarLayerList",
			texType = TextureVariantType.BodyLayer,
			texSubType = "def",
			editors = ["skin"],
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
