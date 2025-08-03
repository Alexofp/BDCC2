extends TextureVariantMany

func _init():
	idprefix = ""
	type = TextureVariantType.HairPattern
	subType = ""
	
	textures = {
		"LongCuteHair_Tips": {
			name = "Tips",
			subType = "LongCuteHair",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/LongCuteHair/Tips.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"ShortHair_Tips": {
			name = "Tips",
			subType = "ShortHair",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/ShortHair/Tips.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"ShortHair_BigStrands": {
			name = "Big Strands",
			subType = "ShortHair",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/ShortHair/BigStrands.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		
		"ShortHair2_Tips": {
			name = "Tips",
			subType = "ShortHair2",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/ShortHair2/Tips.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"ShortHair2_BigStrands": {
			name = "Big Strands",
			subType = "ShortHair2",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/ShortHair2/BigStrands.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
