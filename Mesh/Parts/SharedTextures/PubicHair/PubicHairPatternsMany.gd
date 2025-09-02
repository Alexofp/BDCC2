extends TextureVariantMany

func _init():
	idprefix = "PubicHair_"
	type = TextureVariantType.PubicHairPattern
	subType = "def"
	
	textures = {
		"Cute": {
			name = "Cute",
			colormask = "res://Mesh/Parts/SharedTextures/PubicHair/cute.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Heart": {
			name = "Heart",
			colormask = "res://Mesh/Parts/SharedTextures/PubicHair/heart.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Line": {
			name = "Line",
			colormask = "res://Mesh/Parts/SharedTextures/PubicHair/line.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"LongLine": {
			name = "Long line",
			colormask = "res://Mesh/Parts/SharedTextures/PubicHair/longline.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Lush": {
			name = "Lush",
			colormask = "res://Mesh/Parts/SharedTextures/PubicHair/lush.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Paw": {
			name = "Paw",
			colormask = "res://Mesh/Parts/SharedTextures/PubicHair/paw.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Rectangle": {
			name = "Rectangle",
			colormask = "res://Mesh/Parts/SharedTextures/PubicHair/rectangle.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Square": {
			name = "Square",
			colormask = "res://Mesh/Parts/SharedTextures/PubicHair/square.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
	}
