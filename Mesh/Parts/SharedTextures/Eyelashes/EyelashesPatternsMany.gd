extends TextureVariantMany

func _init():
	idprefix = "Eyelashes_"
	type = TextureVariantType.EyelashesPattern
	subType = "def"
	
	textures = {
		"Eyelashes1": {
			name = "Eyelashes 1",
			colormask = "res://Mesh/Parts/SharedTextures/Eyelashes/EyelashesBig1.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
	}
