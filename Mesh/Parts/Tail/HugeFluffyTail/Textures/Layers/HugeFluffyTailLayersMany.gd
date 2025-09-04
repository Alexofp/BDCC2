extends TextureVariantMany

func _init():
	idprefix = "HugeFluffyTail_"
	type = TextureVariantType.TailPattern
	subType = "HugeFluffyTail"
	
	textures = {
		"Gradient": {
			name = "Gradient",
			colormask = "res://Mesh/Parts/Tail/HugeFluffyTail/Textures/Layers/Gradient.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Tip": {
			name = "Tip",
			colormask = "res://Mesh/Parts/Tail/HugeFluffyTail/Textures/Layers/Tip.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
