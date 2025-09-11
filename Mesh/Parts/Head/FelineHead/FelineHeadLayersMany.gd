extends TextureVariantMany

func _init():
	idprefix = "FelineHead_"
	type = TextureVariantType.HeadLayer
	subType = "FelineHead"
	
	previewDollPartPath = "res://Mesh/Parts/Head/FelineHead/feline_head.tscn"
	
	textures = {
		#"Snout": {
			#name = "Snout",
			#texture = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/FelineSnout.png",
		#},
		#"Lines": {
			#name = "Lines",
			#texture = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Lines.png",
		#},
		"Ferri": {
			name = "Ferri",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Ferri.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Coffee": {
			name = "Coffee",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Coffee.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Geometric": {
			name = "Geometric",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Geometric.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Mark": {
			name = "Mark",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Mark.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
