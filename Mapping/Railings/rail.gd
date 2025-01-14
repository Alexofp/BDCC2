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
		"color": {
			name = "Color",
			type = "colorPalette",
			value = Color.DIM_GRAY,
			BDCC = true,
			basic = true,
		},
	}

func applyEditorOption(_id, _value):
	if(_id == "roughness"):
		setInstanceShaderParameter("roughness_mult", _value)
	if(_id == "color"):
		setInstanceShaderParameter("trim_color_base", _value)
