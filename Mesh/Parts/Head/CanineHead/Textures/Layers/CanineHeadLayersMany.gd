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
			gen = {
				covers = TextureVariant.COVERS_MAIN,
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
			gen = {
				covers = TextureVariant.COVERS_MAIN,
			},
		},
		"Nova": {
			name = "Nova",
			colormask = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/Nova.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_MAIN,
			},
		},
		"EyeDarkness": {
			name = "Eye darkness",
			colormask = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/EyeDarkness.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_EXTRA,
			},
		},
		"Back": {
			name = "Back",
			colormask = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/Back.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_EXTRA,
			},
		},
		"Coffee": {
			name = "Coffee",
			colormask = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/Coffee.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_EXTRA,
				weight = 0.2,
			},
		},
		"Wild": {
			name = "Wild",
			colormask = "res://Mesh/Parts/Head/CanineHead/Textures/Layers/Wild.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_MAIN,
			},
		},
	}
