extends TextureVariantMany

func _init():
	idprefix = "Eyelashes_"
	type = TextureVariantType.EyelashesPattern
	subType = "def"
	
	textures = {
		"Eyelashes1": {
			name = "Eyelashes 1",
			colormask = "res://Mesh/Parts/SharedTextures/Eyelashes/EyelashesBig1.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
			gen = {
				r = GenColorMapTo.COLOR_BLACK,
				g = GenColorMapTo.COLOR_BLACK,
				b = GenColorMapTo.COLOR_BLACK,
			},
		},
		"Eyelashes2": {
			name = "Eyelashes 2",
			colormask = "res://Mesh/Parts/SharedTextures/Eyelashes/Eyelashes2.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
			gen = {
				r = GenColorMapTo.COLOR_BLACK,
				g = GenColorMapTo.COLOR_BLACK,
				b = GenColorMapTo.COLOR_BLACK,
			},
		},
		"Eyelashes3": {
			name = "Eyelashes 3",
			colormask = "res://Mesh/Parts/SharedTextures/Eyelashes/Eyelashes3.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
			gen = {
				r = GenColorMapTo.COLOR_BLACK,
				g = GenColorMapTo.COLOR_BLACK,
				b = GenColorMapTo.COLOR_BLACK,
			},
		},
	}
