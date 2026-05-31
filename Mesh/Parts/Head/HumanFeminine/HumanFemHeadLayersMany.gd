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
	}
