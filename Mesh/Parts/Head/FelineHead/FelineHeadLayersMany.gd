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
		"Muzzle": {
			name = "Muzzle",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Muzzle.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_MAIN,
			},
		},
		"Muzzle2": {
			name = "Muzzle 2",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Muzzle2.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_MAIN,
			},
		},
		"Muzzle3": {
			name = "Muzzle 3",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Muzzle3.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_MAIN,
			},
		},
		"Ferri": {
			name = "Ferri",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Ferri.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_MAIN,
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
			gen = {
				covers = TextureVariant.COVERS_EXTRA,
				weight = 0.2,
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
			gen = {
				covers = TextureVariant.COVERS_MAIN,
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
			gen = {
				covers = TextureVariant.COVERS_EXTRA,
			},
		},
		"CheekMarks": {
			name = "Cheek marks",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/CheekMarks.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_EXTRA,
			},
		},
		"Android": {
			name = "Android",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/Android.png",
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
		"WeirdMarkings": {
			name = "Weird markings",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/WeirdMarkings.png",
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
		"EyeShadow": {
			name = "Eye shadow",
			colormask = "res://Mesh/Parts/Head/FelineHead/Textures/Layers/EyeShadow.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				covers = TextureVariant.COVERS_EXTRA,
			},
		},
	}
