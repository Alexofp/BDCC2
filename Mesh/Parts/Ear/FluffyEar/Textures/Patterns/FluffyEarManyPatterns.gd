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
			gen = {
				r = GenColorMapTo.FLESH_COLOR,
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
			gen = {
				r = GenColorMapTo.FLESH_COLOR,
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
			gen = {
				r = GenColorMapTo.FLESH_COLOR,
				weight = 0.5,
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
			gen = {
				r = GenColorMapTo.FLESH_COLOR,
				weight = 0.2,
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
			gen = {
				r = GenColorMapTo.FLESH_COLOR,
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
			gen = {
				r = GenColorMapTo.FLESH_COLOR,
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
			gen = {
				r = GenColorMapTo.FLESH_COLOR,
			},
		},
	}
