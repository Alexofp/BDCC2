extends TextureVariantMany

func _init():
	idprefix = "RoundEar_"
	type = TextureVariantType.EarPattern
	subType = "RoundEar"
	
	textures = {
		"Default": {
			name = "Default",
			colormask = "res://Mesh/Parts/Ear/RoundEar/Patterns/Default.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Chaos": {
			name = "Chaos",
			colormask = "res://Mesh/Parts/Ear/RoundEar/Patterns/Chaos.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
