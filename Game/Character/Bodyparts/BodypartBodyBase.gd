extends BodypartBase
class_name BodypartBodyBase

var legType:String = "planti" # planti digi
var bodyLayers:Array = []
var breasts:float = 1.0
var nippleShape:float = 0.0
var breastsCleavage:float = 0.0
var breastsSag:float = 0.0
var nipples:Dictionary = {
	id = "Nipple_Default",
	r = Color("f58c8c"),
	g = Color("f7adb2ff"),
	b = Color("bd4040ff"),
}

var nipplePiercing:Array = [""]
var clitPiercing:Array = [""]

var claws:float = 0.0
var clawsColor:Color = Color("855a5a")
var toeClawColor:Color = Color("855a5a")
var handPads:bool = false
var handPadsColor:Color = Color("a6a6a6")
var hindPawPadColor:Color = Color("a6a6a6")

var anusColor:Color = Color("f58c8c")
var anusInColor:Color = Color("f58c8c")

var vagina:bool = true
var vaginaType:int = VaginaType.Normal
var vaginaSize:float = 0.0
var vaginaColor:Color = Color("f58c8c")
var vaginaInColor:Color = Color("f58c8c")
var pubicHair:Dictionary = {
	id = "",
	r = Color("000000ff"),
	g = Color("ff0000ff"),
	b = Color("00ff00ff"),
}

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
			editorZone = CharCreatorZone.Breasts,
		},
		"breastsCleavage": {
			name = "Breast cleavage",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Breasts,
		},
		"breastsSag": {
			name = "Breast sag",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Breasts,
		},
		"nippleShape": {
			name = "Nipples shape",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Breasts,
		},
		"nipples": {
			name = "Nipples pattern",
			type = "pattern",
			texType = TextureVariantType.NipplePattern,
			texSubType = "def",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Breasts,
		},
		"nipplePiercing": {
			name = "Nipple piercings",
			type = "extraColored",
			values = [
				["", "No piercings", 0],
				["p1", "Piercings 1", 1],
				["p2", "Piercings 2", 1],
				["p3", "Piercings 3", 1],
				["p4", "Piercings 4", 2],
			],
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Breasts,
		},
		"legType": {
			name = "Legs",
			type = "selector",
			values = [
				["planti", "Plantigrade"],
				["digi", "Digitigrade"],
			],
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Legs,
		},
		"bodyLayers": {
			name = "Layers",
			type = "texVarLayerList",
			texType = TextureVariantType.BodyLayer,
			texSubType = "def",
			editors = [EDITOR_PART],
		},
		"handPads": {
			name = "Hand pads",
			type = "bool",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Hands,
		},
		"handPadsColor": {
			name = "Hand pads color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Hands,
		},
		"claws": {
			name = "Claws",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Hands,
		},
		"clawsColor": {
			name = "Claw/nail color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Hands,
		},
		"toeClawColor": {
			name = "Toe claw/tail color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Legs,
		},
		"hindPawPadColor": {
			name = "Digi-leg pawpad color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Legs,
		},
		"anusColor": {
			name = "Anus color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Crotch,
		},
		"anusInColor": {
			name = "Anus (inside) color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Crotch,
		},
		"vagina": {
			name = "Vagina",
			type = "bool",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Crotch,
		},
		"vaginaType": {
			name = "Vagina type",
			type = "selector",
			values = [
				[VaginaType.Normal, VaginaType.NAMES[VaginaType.Normal]],
				[VaginaType.Closed, VaginaType.NAMES[VaginaType.Closed]],
				[VaginaType.Spade, VaginaType.NAMES[VaginaType.Spade]],
			],
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Crotch,
		},
		"vaginaSize": {
			name = "Vagina size",
			type = "slider",
			min = 0.0,
			max = 1.0,
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Crotch,
		},
		"vaginaColor": {
			name = "Vagina color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Crotch,
		},
		"vaginaInColor": {
			name = "Vagina (inside) color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Crotch,
		},
		"clitPiercing": {
			name = "Clit piercing",
			type = "extraColored",
			values = [
				["", "No piercings", 0],
				["ring", "Ring", 2],
				["bell", "Bell", 3],
			],
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Crotch,
		},
		"pubicHair": {
			name = "Pubic hair",
			type = "pattern",
			texType = TextureVariantType.PubicHairPattern,
			texSubType = "def",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Crotch,
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

func getDefaultEditorZone() -> int:
	return CharCreatorZone.Body

func supportsPropertyCopyOnBodypartSwitch() -> bool:
	return true

func getListOfPropertiesToCopy() -> Array[String]:
	var theList:Array[String] = []
	for optionID in getOptionsFinal():
		theList.append(optionID)
	theList.erase("breasts")
	theList.erase("breastsCleavage")
	theList.erase("breastsSag")
	return theList

func getLeashTargets() -> Array[String]:
	var possible:Array[String] = ["collar"]
	if(!clitPiercing.is_empty() && !clitPiercing[0].is_empty()):
		possible.append("clitpiercing")
	return possible

func getLeashTargetName(_id:String) -> String:
	if(_id == "clitpiercing"):
		return "clit piercing"
	return _id

func applyOption(_optionID:String, _value:Variant):
	super.applyOption(_optionID, _value)
	
	if(_optionID == "clitPiercing"):
		var theChar := getCharacter()
		if(theChar):
			theChar.triggerLeashpointUpdate()
