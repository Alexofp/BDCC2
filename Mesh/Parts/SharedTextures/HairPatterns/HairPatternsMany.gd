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
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
			},
		},
		"LongHairBow_Tips": {
			name = "Tips",
			subType = "LongHairBow",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/LongCuteHair/Tips.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
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
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
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
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
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
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
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
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
			},
		},
		"CoolBangsHair_Kidlat": {
			name = "Kidlat",
			subType = "CoolBangsHair",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/CoolBangsHair/Kidlat.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
			},
		},
		"LongHair_Coffee": {
			name = "Coffee",
			subType = "LongHair",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/LongHair/Coffee.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
			},
		},
		"Ponytail3_Felina": {
			name = "Felina",
			subType = "Ponytail3",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/Ponytail3/Felina.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
			},
		},
		"SideHair_BigStrands": {
			name = "Big strands",
			subType = "SideHair",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/SideHair/BigStrands.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
			},
		},
		"LongChaosHair_Chaos": {
			name = "Chaos",
			subType = "LongChaosHair",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/LongChaosHair/Chaos.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
			},
		},
		"Ponytail4_Northstar": {
			name = "Northstar",
			subType = "Ponytail4",
			colormask = "res://Mesh/Parts/SharedTextures/HairPatterns/Ponytail4/Northstar.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				r = GenColorMapTo.HAIR_PATTERN_COLOR1,
				g = GenColorMapTo.HAIR_PATTERN_COLOR2,
				b = GenColorMapTo.HAIR_PATTERN_COLOR3,
			},
		},
	}
