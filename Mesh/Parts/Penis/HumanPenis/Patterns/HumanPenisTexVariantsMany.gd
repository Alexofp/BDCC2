extends TextureVariantMany

func _init():
	idprefix = "HumanPenis_"
	type = TextureVariantType.PenisPattern
	subType = "HumanPenis"
	
	textures = {
		"Default": {
			name = "Default",
			colormask = "res://Mesh/Parts/Penis/HumanPenis/Patterns/DefaultPattern.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
