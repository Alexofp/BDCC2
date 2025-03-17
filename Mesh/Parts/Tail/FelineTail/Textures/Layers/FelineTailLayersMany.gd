extends TextureVariantMany

func _init():
	idprefix = "FelineTail_"
	type = TextureVariantType.TailPattern
	subType = "FelineTail"
	
	textures = {
		"Default": {
			name = "No pattern",
			colormask = "",
			flags = {
				hasR=false,
				hasG=false,
				hasB=false,
			},
		},
		"LionTip": {
			name = "Lion tip",
			colormask = "res://Mesh/Parts/Tail/FelineTail/Textures/Layers/LionTip.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Gradient": {
			name = "Gradient",
			colormask = "res://Mesh/Parts/Tail/FelineTail/Textures/Layers/Gradient.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Tiger": {
			name = "Tiger",
			colormask = "res://Mesh/Parts/Tail/FelineTail/Textures/Layers/Tiger.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
