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
		"Belly2": {
			name = "Belly 2",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly2.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Belly3": {
			name = "Belly 3",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly3.png",
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
		"HeartBreasts": {
			name = "Heart on breasts",
			texture = "res://Mesh/Parts/SharedTextures/BodyLayers/HeartBreasts.png",
			flags = {
				rect = [0.4443359375, 0.10205078125, 0.0625, 0.0625],
			},
		},
		"Lighting": {
			name = "Lighting",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Lighting.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Coffee": {
			name = "Coffee",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Coffee.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Nova": {
			name = "Nova",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Nova.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
