extends TextureVariantMany

func _init():
	idprefix = "FluffyEar_"
	type = TextureVariantType.EarPattern
	subType = "FluffyEar"
	
	textures = {
		"Default": {
			name = "Default",
			colormask = "res://Mesh/Parts/Ear/FluffyEar/Textures/Patterns/JustInnerEar.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Dots": {
			name = "Dots",
			colormask = "res://Mesh/Parts/Ear/FluffyEar/Textures/Patterns/Dots.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
