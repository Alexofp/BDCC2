extends TextureVariantMany

func _init():
	idprefix = "Body_"
	type = TextureVariantType.BodyLayer
	subType = "def"
	previewDollPartPath = "res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn"
	
	textures = {
		"Belly": {
			name = "Belly",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"FeetFur": {
			name = "Feet fur",
			texture = "res://Mesh/Parts/SharedTextures/BodyLayers/FeetFur.png",
			flags = {
			},
		},
		"HandsFur": {
			name = "Hands fur",
			texture = "res://Mesh/Parts/SharedTextures/BodyLayers/HandsFur.png",
			flags = {
			},
		},
		"Ferri": {
			name = "Ferri",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Ferri.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Artica": {
			name = "Artica",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Artica.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
