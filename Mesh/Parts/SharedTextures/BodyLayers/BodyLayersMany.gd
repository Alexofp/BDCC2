extends TextureVariantMany

func _init():
	idprefix = "Body_"
	type = TextureVariantType.BodyLayer
	subType = "def"
	previewDollPartPath = "res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn"
	
	textures = {
		"TestLayer": {
			texture = "res://Mesh/Parts/SharedTextures/BodyLayers/TestLayer.png",
		},
		"ColormaskTest": {
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/ColormaskTest.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Belly": {
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"FeetFur": {
			texture = "res://Mesh/Parts/SharedTextures/BodyLayers/FeetFur.png",
			flags = {
			},
		},
		"HandsFur": {
			texture = "res://Mesh/Parts/SharedTextures/BodyLayers/HandsFur.png",
			flags = {
			},
		},
		"Ferri": {
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Ferri.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Artica": {
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Artica.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
