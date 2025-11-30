extends BodypartBase
class_name BodypartHairBase

#var color1:Color = Color("630909")
#var color2:Color = Color("b84949")
#var color3:Color = Color("b82828")
var colorRoot:Color = Color("db1c1c")
var colorTip:Color = Color("750000")
var shading:float = 0.5

var pattern:Dictionary = {
	id = "",
	r = Color(0.7, 0.7, 0.7),
	g = Color(0.5, 0.5, 0.5),
	b = Color(0.3, 0.3, 0.3),
}

func getBodypartType() -> int:
	return BodypartType.Hair

func getOptions() -> Dictionary:
	var theOptions:Dictionary = {
		"colorRoot": {
			name = "Roots color",
			type = "color",
			editors = [EDITOR_PART],
		},
		"colorTip": {
			name = "Tips color",
			type = "color",
			editors = [EDITOR_PART],
		},
		"shading": {
			name = "Shading",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
		},
		#"color1": {
			#name = "Color 1",
			#type = "color",
			#editors = [EDITOR_PART],
		#},
		#"color2": {
			#name = "Color 2",
			#type = "color",
			#editors = [EDITOR_PART],
		#},
		#"color3": {
			#name = "Color 3",
			#type = "color",
			#editors = [EDITOR_PART],
		#},
	}
	
	theOptions["pattern"] = {
			name = "Pattern",
			type = "pattern",
			texType = TextureVariantType.HairPattern,
			texSubType = id,
			editors = [EDITOR_PART],
		}
	
	return theOptions

func getDefaultEditorZone() -> int:
	return CharCreatorZone.Head

func supportsPropertyCopyOnBodypartSwitch() -> bool:
	return true

func getListOfPropertiesToCopy() -> Array[String]:
	return [
		"colorRoot",
		"colorTip",
		"shading",
	]
