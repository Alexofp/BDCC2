extends TextureVariantMany

func _init():
	idprefix = "FelineHead_"
	type = TextureVariantType.HeadLayer
	subType = "FelineHead"
	
	textures = {
		"Snout": {
			name = "Snout",
			texture = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/FelineSnout.png",
		},
		"Lines": {
			name = "Lines",
			texture = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Lines.png",
		},
		"Ferri": {
			name = "Ferri",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Ferri.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
