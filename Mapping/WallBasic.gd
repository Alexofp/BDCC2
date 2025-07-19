@tool
extends PropBasic

@export var roughness:float = 0.5:
	set(value):
		roughness = value
		notifySetEditorValue("roughness", value)
@export var colorbase:Color = Color("868686"):
	set(value):
		colorbase = value
		notifySetEditorValue("colorbase", value)
@export var color1:Color = Color("353535"):
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
		"colorbase": {
			name = "Main Color",
			type = "colorPalette",
			BDCC = true,
			basic = true,
		},
		"color1": {
			name = "Color 1",
			type = "colorPalette",
			BDCC = true,
			basic = true,
		},
	}

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_WALL
