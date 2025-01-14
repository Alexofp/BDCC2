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
			name = "Base Color",
			type = "colorPalette",
			value = Color("d8a300"),
			BDCC = true,
			basic = true,
			palette = [Color("d8a300"), Color("303030")],
		},
		"color": {
			name = "Main Color",
			type = "colorPalette",
			value = Color("303030"),
			BDCC = true,
			basic = true,
			palette = [Color("d8a300"), Color("303030")],
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
			value = Color("fffea4"),
			light = true,
		},
	}

func applyEditorOption(_id, _value):
	if(_id == "roughness"):
		setInstanceShaderParameter("roughness_mult", _value)
	if(_id == "colorbase"):
		setInstanceShaderParameter("trim_color_base", _value)
	if(_id == "color"):
		setInstanceShaderParameter("trim_color_main", _value)
	if(_id == "color2"):
		setInstanceShaderParameter("trim_color_second", _value)
	if(_id == "color3"):
		setInstanceShaderParameter("trim_color_third", _value)
		$SpotLight3D2.light_color = _value
