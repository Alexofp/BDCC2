extends PropBasic

@export var roughness:float = 0.5
@export var colorbase:Color = Color("868686")
@export var color1:Color = Color("303030")
@export var color3:Color = Color("00E0FF")

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
			name = "Base Color",
			type = "colorPalette",
			BDCC = true,
			basic = true,
		},
		"color1": {
			name = "Main Color",
			type = "colorPalette",
			value = Color("303030"),
			BDCC = true,
			basic = true,
		},
		#"color2": {
			#name = "Color 2",
			#type = "colorPalette",
			#value = Color.WHITE,
			#BDCC = true,
			#basic = true,
		#},
		"color3": {
			name = "Light Color",
			type = "colorPalette",
			value = Color("00E0FF"),
			light = true,
		},
	}

func applyEditorOption(_id, _value):
	if(_id == "roughness"):
		setInstanceShaderParameter("roughness_mult", _value)
	if(_id == "colorbase"):
		setInstanceShaderParameter("trim_color_base", _value)
	if(_id == "color1"):
		setInstanceShaderParameter("trim_color_main", _value)
	if(_id == "color2"):
		setInstanceShaderParameter("trim_color_second", _value)
	if(_id == "color3"):
		setInstanceShaderParameter("trim_color_third", _value)
		$WallLight/SpotLight3D.light_color = _value

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_WALLLIGHT
