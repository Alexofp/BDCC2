extends TextureVariantMany

func _init():
	idprefix = "DragonTail_"
	type = TextureVariantType.TailPattern
	subType = "DragonTail"
	
	textures = {
		"Default": {
			name = "Default",
			colormask = "res://Mesh/Parts/Tail/DragonTail/Textures/Layers/DragonTailDefault.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Ferri": {
			name = "Ferri",
			colormask = "res://Mesh/Parts/Tail/DragonTail/Textures/Layers/DragonTailFerri.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
