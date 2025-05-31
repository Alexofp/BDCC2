extends BodypartBase
class_name BodypartHornBase

var hornColor:Color = Color(0.2, 0.2, 0.2)
var hornScale:float = 1.0
var hornSideShift:float = 0.0
var hornForwardShift:float = 0.0

func getBodypartType() -> int:
	return BodypartType.Horn

func getOptions() -> Dictionary:
	return {
		"hornScale": {
			name = "Size",
			type = "slider",
			min = 0.5,
			max = 1.5,
			editors = [EDITOR_PART],
		},
		"hornSideShift": {
			name = "Horizontal shift",
			type = "slider",
			min = -0.2,
			max = 0.2,
			editors = [EDITOR_PART],
		},
		"hornForwardShift": {
			name = "Forward shift",
			type = "slider",
			min = -0.2,
			max = 0.2,
			editors = [EDITOR_PART],
		},
		"hornColor": {
			name = "Color",
			type = "color",
			editors = [EDITOR_PART],
		},
	}
