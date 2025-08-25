extends TextureVariantMany

func _init():
	idprefix = "CanineHead_"
	type = TextureVariantType.HeadLayer
	subType = "CanineHead"
	
	previewDollPartPath = "res://Mesh/Parts/Head/CanineHead/canine_head.tscn"
	
	textures = {
		#"Snout": {
			#name = "Snout",
			#texture = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/Snout.png",
		#},
		#"Lines": {
			#name = "Lines",
			#texture = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/Lines.png",
		#},
		"Artica": {
			name = "Artica",
			colormask = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/Artica.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
