extends TextureVariantMany

func _init():
	idprefix = "Eye_"
	type = TextureVariantType.EyePattern
	subType = "def"
	
	textures = {
		"Normal": {
			name = "Normal",
			colormask = "res://Mesh/Parts/SharedTextures/Eyes/eye_colormask.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.EYE_COLOR1,
				g = GenColorMapTo.EYE_COLOR2,
				b = GenColorMapTo.EYE_COLOR3,
			},
		},
		"Animal": {
			name = "Animal",
			colormask = "res://Mesh/Parts/SharedTextures/Eyes/eye_animal.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.EYE_COLOR1,
				g = GenColorMapTo.EYE_COLOR2,
				b = GenColorMapTo.EYE_COLOR3,
			},
		},
		"Robot": {
			name = "Robot",
			colormask = "res://Mesh/Parts/SharedTextures/Eyes/eye_robot.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.EYE_COLOR1,
				g = GenColorMapTo.EYE_COLOR2,
				b = GenColorMapTo.FUR_COLOR_PICK,
			},
		},
		"Demon": {
			name = "Demon",
			colormask = "res://Mesh/Parts/SharedTextures/Eyes/eye_demon.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.EYE_COLOR1,
				g = GenColorMapTo.EYE_COLOR2,
				b = GenColorMapTo.RANDOM_COLOR_VIBRANT,
			},
		},
		"Mystic": {
			name = "Mystic",
			colormask = "res://Mesh/Parts/SharedTextures/Eyes/eye_mystic.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.EYE_COLOR1,
				g = GenColorMapTo.EYE_COLOR2,
				b = GenColorMapTo.EYE_COLOR3,
			},
		},
	}
