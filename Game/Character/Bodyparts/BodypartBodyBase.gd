extends BodypartBase
class_name BodypartBodyBase

var legType:String = "planti" # planti digi
var bodyLayers:Array = []
var breasts:float = 1.0
var nippleShape:float = 0.0
var breastsCleavage:float = 0.0
var breastsSag:float = 0.5
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

func generateFor(_gen:CharacterGenerator):
	if(_gen.breasts == _gen.YES):
		breasts = randf_range(0.4, 1.5)
		if(_gen.character.thickness >= 1.5 && RNG.chance(10.0)):
			breasts = randf_range(1.5, 2.0)
	else:
		breasts = 0.0
	legType = "planti" if !_gen.hasTrait(SpeciesTrait.LegsDigi) else "digi"
	
	if(!_gen.hasTrait(SpeciesTrait.HandsPaws)):
		claws = RNG.randfRange(0.0, 0.5)
		handPads = false
	else:
		claws = clampf(RNG.randfRange(0.7, 1.2), 0.0, 1.0)
		handPads = true
	
	vagina = (_gen.vagina == _gen.YES)
	if(_gen.hasTrait(SpeciesTrait.CanineVagina)):
		vaginaType = VaginaType.Spade
	else:
		vaginaType = VaginaType.Normal if RNG.chance(70.0) else VaginaType.Closed
	#GEN: Public hair
	
	# Hardcoded for nekos
	if(_gen.species.size() > 1 && _gen.species.has("Human")):
		generateSkinLayer(bodyLayers, _gen, TextureVariantType.BodyLayer, "def", TextureVariant.COVERS_ARMS_NEKO)
		generateSkinLayer(bodyLayers, _gen, TextureVariantType.BodyLayer, "def", TextureVariant.COVERS_LEGS_NEKO)
	
	if(!_gen.hasTrait(SpeciesTrait.BodyNoBodySkin)):
		generateSkinLayerMain(bodyLayers, _gen, TextureVariantType.BodyLayer, "def")
		clawsColor = _gen.colors.nails
		toeClawColor = _gen.colors.nails
		
		if(RNG.chance(50.0)):
			generateSkinLayer(bodyLayers, _gen, TextureVariantType.BodyLayer, "def", TextureVariant.COVERS_ARMS)
		if(RNG.chance(50.0)):
			generateSkinLayer(bodyLayers, _gen, TextureVariantType.BodyLayer, "def", TextureVariant.COVERS_LEGS)
		if(RNG.chance(50.0)):
			generateSkinLayer(bodyLayers, _gen, TextureVariantType.BodyLayer, "def", TextureVariant.COVERS_EXTRA)
	else:
		clawsColor = _gen.colors.claws
		toeClawColor = _gen.colors.claws
	
	if(RNG.chance(3.0)):
		generateSkinLayer(bodyLayers, _gen, TextureVariantType.BodyLayer, "def", TextureVariant.COVERS_TATTOO)

	
	handPadsColor = _gen.colors.pawPads
	hindPawPadColor = _gen.colors.pawPads
	vaginaColor = _gen.colors.privates
	vaginaInColor = ColorUtils.shadow(_gen.colors.privates)
	anusColor = vaginaColor
	anusInColor = vaginaInColor
	
	#nipples["r"] = _gen.colors.privates
	#nipples["g"] = ColorUtils.shadow(_gen.colors.privates)
	#nipples["b"] = ColorUtils.highlight(_gen.colors.privates)
	pickPattern(nipples, _gen, TextureVariantType.NipplePattern, "def")
	
	pickPiercings(nipplePiercing, ["p1", "p2", "p3", "p4"], 30.0, [
		_gen.colors.piercingMetal, _gen.colors.piercingColor, _gen.colors.piercingColor, _gen.colors.piercingColor
	])
	if(vagina):
		pickPiercings(clitPiercing, ["ring", "ring", "ring", "ring", "ring", "bell"], 30.0, [
			_gen.colors.piercingMetal, _gen.colors.piercingColor, _gen.colors.piercingColor, _gen.colors.piercingColor
		])

func pickPiercings(_ar:Array, _possibleVals:Array[String], _chance:float, _colors:Array[Color]):
	if(!RNG.chance(_chance) || _possibleVals.is_empty()):
		_ar.clear()
		_ar.append("")
		return
	_ar.clear()
	_ar.append(RNG.pick(_possibleVals))
	_ar.append_array(_colors)

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
