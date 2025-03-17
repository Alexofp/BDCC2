@tool
extends "res://Mapping/Props/WallLight.gd"

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
		$LampCeiling/SpotLight3D.light_color = _value
