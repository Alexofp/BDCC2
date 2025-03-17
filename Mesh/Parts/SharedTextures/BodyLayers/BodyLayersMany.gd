extends TextureVariantMany

func _init():
	idprefix = ""
	type = TextureVariantType.BodyLayer
	subType = "def"
	
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
	}
