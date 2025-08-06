extends BodypartBase
class_name BodypartHeadBase

var eyeColor1:Color = Color("0066ea")
var eyeColor2:Color = Color("00a1ff")
var eyeColor3:Color = Color.WHITE
var mouthColor:Color = Color("9e352e")
var tongueColor:Color = Color("9e352e")
var teethColor:Color = Color("ffe8db")

var faceOverride:Dictionary = {
	fields = {},
	values = {},
}

func getBodypartType() -> int:
	return BodypartType.Head

func getOptions() -> Dictionary:
	return {
		"eyeColor1": {
			name = "Eye color 1",
			type = "color",
			editors = [EDITOR_PART],
		},
		"eyeColor2": {
			name = "Eye color 2",
			type = "color",
			editors = [EDITOR_PART],
		},
		"eyeColor3": {
			name = "Eye color 3",
			type = "color",
			editors = [EDITOR_PART],
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
		},
		"tongueColor": {
			name = "Tongue color",
			type = "color",
			editors = [EDITOR_PART],
		},
		"teethColor": {
			name = "Teeth color",
			type = "color",
			editors = [EDITOR_PART],
		},
	}
