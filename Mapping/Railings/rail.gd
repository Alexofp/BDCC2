@tool
extends PropBasic

@export var roughness:float = 0.5:
	set(value):
		roughness = value
		notifySetEditorValue("roughness", value)
@export var color1:Color = Color.DIM_GRAY:
	set(value):
		color1 = value
		notifySetEditorValue("color1", value)

func getEditorOptions() -> Dictionary:
	return {
		"roughness": {
			name = "Roughness",
			type = "floatPresets",
			step = 0.01,
			presets = [
				0.0, 0.1, 0.25, 0.4, 0.5, 0.6, 0.75, 0.9, 1.0,
			],
		},
		"color1": {
			name = "Color",
			type = "colorPalette",
			BDCC = true,
			basic = true,
		},
	}

func applyEditorOption(_id, _value):
	if(_id == "roughness"):
		setInstanceShaderParameter("roughness_mult", _value)
	if(_id == "color1"):
		setInstanceShaderParameter("trim_color_base", _value)
