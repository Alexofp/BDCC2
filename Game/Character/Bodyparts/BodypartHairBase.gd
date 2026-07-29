extends BodypartBase
class_name BodypartHairBase

#var color1:Color = Color("630909")
#var color2:Color = Color("b84949")
#var color3:Color = Color("b82828")
var colorRoot:Color = Color("db1c1c")
var colorTip:Color = Color("750000")
var shading:float = 0.5
var shine:float = 0.3

var pattern:Dictionary = {
	id = "",
	r = Color(0.7, 0.7, 0.7),
	g = Color(0.5, 0.5, 0.5),
	b = Color(0.3, 0.3, 0.3),
}

var mascWeight:float = 1.0
var femWeight:float = 1.0
var androWeight:float = 1.0

func registerForSpecies():
	addForAll(BodypartSlot.Hair, Gender.Male, mascWeight)
	addForAll(BodypartSlot.Hair, Gender.Female, femWeight)
	addForAll(BodypartSlot.Hair, Gender.Androgynous, androWeight)
	addForAll(BodypartSlot.Hair, Gender.NonBinary, androWeight)

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	colorRoot = _gen.colors.hair.color1
	colorTip = ColorUtils.shade(colorTip, randf_range(0.3, 0.7))
	shading = randf_range(0.0, 1.0)
	shine = randf_range(0.2, 0.4)
	#GEN: Pick random pattern and colors

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
		"shine": {
			name = "Shine",
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
