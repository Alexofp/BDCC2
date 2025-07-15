extends "res://Mapping/Props/WallLight.gd"

func applyEditorOption(_id, _value):
	match _id:
		"roughness":
			setInstanceShaderParameter("roughness_mult", _value)
		"colorbase":
			setInstanceShaderParameter("trim_color_base", _value)
		"color":
			setInstanceShaderParameter("trim_color_main", _value)
		"color2":
			setInstanceShaderParameter("trim_color_second", _value)
		"color3":
			setInstanceShaderParameter("trim_color_third", _value)
			$LampCeiling/SpotLight3D.light_color = _value
