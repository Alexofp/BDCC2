extends TextureVariantMany

func _init():
	idprefix = "Nipple_"
	type = TextureVariantType.NipplePattern
	subType = "def"
	
	textures = {
		"Default": {
			name = "Default",
			colormask = "res://Mesh/Parts/SharedTextures/Nipples/nippleSmall.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Big": {
			name = "Big",
			colormask = "res://Mesh/Parts/SharedTextures/Nipples/nippleBig.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Smooth": {
			name = "Smooth",
			colormask = "res://Mesh/Parts/SharedTextures/Nipples/smooth.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"SmoothSmall": {
			name = "SmoothSmall",
			colormask = "res://Mesh/Parts/SharedTextures/Nipples/smoothSmall.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
