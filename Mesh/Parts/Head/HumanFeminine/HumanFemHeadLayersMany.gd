extends TextureVariantMany

func _init():
	idprefix = "HumanFeminineHead_"
	type = TextureVariantType.HeadLayer
	subType = "HumanFeminineHead"
	
	previewDollPartPath = "res://Mesh/Parts/Head/HumanFeminine/my_human_head.tscn"
	
	textures = {
		"Lips": {
			name = "Lips",
			colormask = "res://Mesh/Parts/Head/HumanFeminine/Textures/Skins/Lips.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"EyeShadow": {
			name = "Eye shadow",
			colormask = "res://Mesh/Parts/Head/HumanFeminine/Textures/Skins/EyeShadow.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"HairCap": {
			name = "Hair cap",
			colormask = "res://Mesh/Parts/Head/HumanFeminine/Textures/Skins/HairCap.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Freckles": {
			name = "Freckles",
			colormask = "res://Mesh/Parts/Head/HumanFeminine/Textures/Skins/Freckles.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Blush": {
			name = "Blush",
			colormask = "res://Mesh/Parts/Head/HumanFeminine/Textures/Skins/Blush.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
