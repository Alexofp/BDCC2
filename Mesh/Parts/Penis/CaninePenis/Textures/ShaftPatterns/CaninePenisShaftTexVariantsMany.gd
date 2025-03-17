extends TextureVariantMany

func _init():
	idprefix = "CanineShaft_"
	type = TextureVariantType.PenisPattern
	subType = "CanineShaft"
	
	textures = {
		"Default": {
			name = "Default",
			colormask = "res://Mesh/Parts/Penis/CaninePenis/Textures/ShaftPatterns/Default.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"NoPattern": {
			name = "No pattern",
			colormask = "",
			flags = {
				hasR=false,
				hasG=false,
				hasB=false,
			},
		},
	}
