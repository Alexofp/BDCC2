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
	}
