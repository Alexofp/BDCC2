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
