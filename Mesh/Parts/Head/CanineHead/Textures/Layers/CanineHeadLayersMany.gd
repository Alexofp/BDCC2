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
				main = true,
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
				main = true,
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
				main = true,
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
				main = true,
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
				main = true,
			},
		},
	}
