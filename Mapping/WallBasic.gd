@tool
extends PropBasic

func getEditorOptions() -> Dictionary:
	return {
		"roughness": {
			name = "Roughness",
			type = "floatPresets",
			value = 0.5,
			step = 0.01,
			presets = [
				0.0, 0.1, 0.25, 0.4, 0.5, 0.6, 0.75, 0.9, 1.0,
			],
		},
		"colorbase": {
			name = "Main Color",
			type = "colorPalette",
			value = Color("868686"),
			BDCC = true,
			basic = true,
		},
		"color1": {
			name = "Color 1",
			type = "colorPalette",
			value = Color("353535"),
			BDCC = true,
			basic = true,
		},
	}
