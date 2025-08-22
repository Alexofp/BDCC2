extends TextureVariantMany

func _init():
	idprefix = "LongTail_"
	type = TextureVariantType.TailPattern
	subType = "LongTail"
	
	textures = {
		"LionTip": {
			name = "Lion tip",
			colormask = "res://Mesh/Parts/Tail/LongTail/Textures/Layers/LionTip.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Gradient": {
			name = "Gradient",
			colormask = "res://Mesh/Parts/Tail/LongTail/Textures/Layers/Gradient.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Tiger": {
			name = "Tiger",
			colormask = "res://Mesh/Parts/Tail/LongTail/Textures/Layers/Tiger.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Burger": {
			name = "Burger",
			colormask = "res://Mesh/Parts/Tail/LongTail/Textures/Layers/Burger.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
