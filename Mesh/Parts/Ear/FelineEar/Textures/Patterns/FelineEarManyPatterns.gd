extends TextureVariantMany

func _init():
	idprefix = "FelineEar_"
	type = TextureVariantType.EarPattern
	subType = "FelineEar"
	
	textures = {
		"Default": {
			name = "Default",
			colormask = "res://Mesh/Parts/Ear/FelineEar/Textures/Patterns/JustInnerEar.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Dots": {
			name = "Dots",
			colormask = "res://Mesh/Parts/Ear/FelineEar/Textures/Patterns/Dots.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
