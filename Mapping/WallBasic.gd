@tool
extends PropBasic

@export var roughness:float = 0.5:
	set(value):
		roughness = value
		notifySetEditorValue("roughness", value)
@export var colorbase:Color = Color("4d4d4d"):
	set(value):
		colorbase = value
		notifySetEditorValue("colorbase", value)
@export var color1:Color = Color("141414"):
	set(value):
		color1 = value
		notifySetEditorValue("color1", value)
#@export var uvShift:float = 0.0:
	#set(value):
		#uvShift = value
		#notifySetEditorValue("uvShift", value)

@export var shiftUVs:bool = true:
	set(value):
		shiftUVs = value

func _ready() -> void:
	super._ready()
	if(!Engine.is_editor_hint()):
		setInstanceShaderParameter("uvShift", randf_range(-1.0, 1.0) if shiftUVs else 0.0)
	#uvShift = randf_range(-1.0, 1.0)

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
