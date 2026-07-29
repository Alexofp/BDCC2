extends TextureVariantMany

func _init():
	idprefix = "Body_"
	type = TextureVariantType.BodyLayer
	subType = "def"
	previewDollPartPath = "res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn"
	
	textures = {
		"Belly": {
			name = "Belly",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
			},
		},
		"Belly2": {
			name = "Belly 2",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly2.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
			},
		},
		"Belly3": {
			name = "Belly 3",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly3.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
			},
		},
		"Belly4": {
			name = "Belly 4",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly4.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
			},
		},
		"Belly5": {
			name = "Belly 5",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly5.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
			},
		},
		"Belly6": {
			name = "Belly 6",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly6.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
			},
		},
		"Belly7": {
			name = "Belly 7",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Belly7.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
			},
		},
		"FeetFur": {
			name = "Feet fur",
			texture = "res://Mesh/Parts/SharedTextures/BodyLayers/FeetFur.png",
			flags = {
			},
		},
		"HandsFur": {
			name = "Hands fur",
			texture = "res://Mesh/Parts/SharedTextures/BodyLayers/HandsFur.png",
			flags = {
			},
		},
		"LegFur": {
			name = "Leg fur",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/LegFur.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"ArmFur": {
			name = "Arm fur",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/ArmFur.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Ferri": {
			name = "Ferri",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Ferri.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
				weight = 0.2,
			},
		},
		"Artica": {
			name = "Artica",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Artica.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
				weight = 0.2,
			},
		},
		"HeartBreasts": {
			name = "Heart on breasts",
			texture = "res://Mesh/Parts/SharedTextures/BodyLayers/HeartBreasts.png",
			flags = {
				rect = [0.4443359375, 0.10205078125, 0.0625, 0.0625],
			},
		},
		"Lighting": {
			name = "Lighting",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Lighting.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Coffee": {
			name = "Coffee",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Coffee.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Nova": {
			name = "Nova",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Nova.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
				weight = 0.2,
			},
		},
		"Back1": {
			name = "Back 1",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Back1.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Back2": {
			name = "Back 2",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Back2.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"ThighHighs": {
			name = "Thigh highs",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/ThighHighs.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"GlovesFingerless": {
			name = "Gloves fingerless",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/GlovesFingerless.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"Scars": {
			name = "Scars",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Scars.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"WeirdMarkings": {
			name = "Weird markings",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/WeirdMarkings.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"ChaosStripes": {
			name = "Chaos stripes",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/ChaosStripes.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"FeetPlain": {
			name = "Feet plain",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/FeetPlain.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"HandsPlain": {
			name = "Hands plain",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/HandsPlain.png",
			flags = {
				hasR=true,
				hasG=false,
				hasB=false,
			},
		},
		"Wild": {
			name = "Wild",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/Wild.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
			gen = {
				main = true,
				weight = 0.2,
			},
		},
		"WildMarks": {
			name = "Wild marks",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/WildMarks.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"WildBack": {
			name = "Wild back",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/WildBack.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"WildTattoo": {
			name = "Wild tattoo",
			colormask = "res://Mesh/Parts/SharedTextures/BodyLayers/WildTattoo.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=false,
			},
		},
	}
