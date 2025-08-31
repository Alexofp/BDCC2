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
		},
		"Animal": {
			name = "Animal",
			colormask = "res://Mesh/Parts/SharedTextures/Eyes/eye_animal.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
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
		},
		"Demon": {
			name = "Demon",
			colormask = "res://Mesh/Parts/SharedTextures/Eyes/eye_demon.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
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
		},
	}
