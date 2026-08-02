extends TextureVariantMany

func _init():
	idprefix = "SmallEar_"
	type = TextureVariantType.EarPattern
	subType = "SmallEar"
	
	textures = {
		"Default": {
			name = "Default",
			colormask = "res://Mesh/Parts/Ear/SmallEar/Patterns/Default.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
			gen = {
				r = GenColorMapTo.FLESH_COLOR,
			},
		},
		"Fancy": {
			name = "Fancy",
			colormask = "res://Mesh/Parts/Ear/SmallEar/Patterns/Fancy.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.FLESH_COLOR,
			},
		},
	}
