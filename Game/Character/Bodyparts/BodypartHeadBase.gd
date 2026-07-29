extends BodypartBase
class_name BodypartHeadBase

var eyes:Dictionary = {
	id = "Eye_Normal",
	r = Color("0066ea"),
	g = Color("00a1ff"),
	b = Color(Color.WHITE),
}
var mouthColor:Color = Color("9e352e")
var tongueColor:Color = Color("9e352e")
var teethColor:Color = Color("ffe8db")
var brows:Dictionary = {
	id = "Brow_Brow1",
	r = Color("000000ff"),
	g = Color("ff0000ff"),
	b = Color("00ff00ff"),
}
var eyelashes:Dictionary = {
	id = "Eyelashes_Eyelashes1",
	r = Color("000000ff"),
	g = Color("ff0000ff"),
	b = Color("00ff00ff"),
}

var faceOverride:Dictionary = {
	fields = {},
	values = {},
}

func generateFor(_gen:CharacterGenerator):
	super.generateFor(_gen)
	
	eyes["r"] = _gen.colors.eyeL.color1
	eyes["g"] = _gen.colors.eyeL.color2
	eyes["b"] = _gen.colors.eyeL.color3
	if(_gen.colors.eyeL != _gen.colors.eyeR):
		eyes["id2"] = eyes["id"]
		eyes["r2"] = _gen.colors.eyeR.color1
		eyes["g2"] = _gen.colors.eyeR.color2
		eyes["b2"] = _gen.colors.eyeR.color3
	
	#GEN: Pick eyelashes/brows
	#GEN: Pick mouth colors

func getBodypartType() -> int:
	return BodypartType.Head

func getOptions() -> Dictionary:
	return {
		"eyes": {
			name = "Pattern",
			type = "eyePattern",
			texType = TextureVariantType.EyePattern,
			texSubType = "def",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Eyes,
		},
		"brows": {
			name = "Brows",
			type = "pattern",
			texType = TextureVariantType.BrowPattern,
			texSubType = "def",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Eyes,
		},
		"eyelashes": {
			name = "Eyelashes",
			type = "pattern",
			texType = TextureVariantType.EyelashesPattern,
			texSubType = "def",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Eyes,
		},
		"faceOverride": {
			name = "Face expression",
			type = "faceOverride",
			editors = [EDITOR_INTERACT],
		},
		
		"mouthColor": {
			name = "Mouth color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Mouth,
		},
		"tongueColor": {
			name = "Tongue color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Mouth,
		},
		"teethColor": {
			name = "Teeth color",
			type = "color",
			editors = [EDITOR_PART],
			editorZone = CharCreatorZone.Mouth,
		},
	}

func getDefaultEditorZone() -> int:
	return CharCreatorZone.Face
