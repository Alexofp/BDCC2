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
			gen = {
				r = GenColorMapTo.NIPPLE_COLOR,
				g = GenColorMapTo.NIPPLE_COLOR,
				b = GenColorMapTo.NIPPLE_COLOR,
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
			gen = {
				r = GenColorMapTo.NIPPLE_COLOR,
				g = GenColorMapTo.NIPPLE_COLOR,
				b = GenColorMapTo.NIPPLE_COLOR,
				weight = 0.2,
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
			gen = {
				r = GenColorMapTo.NIPPLE_COLOR,
				g = GenColorMapTo.NIPPLE_COLOR_DARK,
				b = GenColorMapTo.NIPPLE_COLOR_HIGHLIGHT,
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
			gen = {
				r = GenColorMapTo.NIPPLE_COLOR,
				g = GenColorMapTo.NIPPLE_COLOR_DARK,
				b = GenColorMapTo.NIPPLE_COLOR_HIGHLIGHT,
				weight = 0.2,
			},
		},
	}
