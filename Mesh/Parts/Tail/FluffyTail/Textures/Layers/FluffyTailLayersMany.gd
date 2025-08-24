extends TextureVariantMany

func _init():
	idprefix = "FluffyTail_"
	type = TextureVariantType.TailPattern
	subType = "FluffyTail"
	
	textures = {
		"Default": {
			name = "Default",
			colormask = "res://Mesh/Parts/Tail/FluffyTail/Textures/Layers/Default.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
