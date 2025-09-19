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
		"Gradient": {
			name = "Gradient",
			colormask = "res://Mesh/Parts/Ear/FluffyEar/Textures/Patterns/Gradient.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
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
		"WeirdMarkings": {
			name = "Weird markings",
			colormask = "res://Mesh/Parts/Ear/FluffyEar/Textures/Patterns/WeirdMarkings.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Square": {
			name = "Square",
			colormask = "res://Mesh/Parts/Ear/FluffyEar/Textures/Patterns/Square.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Geometric": {
			name = "Geometric",
			colormask = "res://Mesh/Parts/Ear/FluffyEar/Textures/Patterns/Geometric.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Tip": {
			name = "Tip",
			colormask = "res://Mesh/Parts/Ear/FluffyEar/Textures/Patterns/Tip.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
