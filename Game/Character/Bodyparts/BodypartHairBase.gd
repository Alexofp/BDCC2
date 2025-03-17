extends BodypartBase
class_name BodypartHairBase

var color1:Color = Color("630909")
var color2:Color = Color("b84949")
var color3:Color = Color("b82828")

func getBodypartType() -> String:
	return BodypartType.Hair

func getOptions() -> Dictionary:
	return {
		"color1": {
			name = "Color 1",
			type = "color",
			editors = ["part"],
		},
		"color2": {
			name = "Color 2",
			type = "color",
			editors = ["part"],
		},
		"color3": {
			name = "Color 3",
			type = "color",
			editors = ["part"],
		},
	}
