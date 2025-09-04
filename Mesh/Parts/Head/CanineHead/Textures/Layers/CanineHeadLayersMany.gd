extends TextureVariantMany

func _init():
	idprefix = "CanineHead_"
	type = TextureVariantType.HeadLayer
	subType = "CanineHead"
	
	previewDollPartPath = "res://Mesh/Parts/Head/CanineHead/canine_head.tscn"
	
	textures = {
		"Artica": {
			name = "Artica",
			colormask = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/Artica.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Muzzle": {
			name = "Muzzle",
			colormask = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/Muzzle.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
