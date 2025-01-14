@tool
extends Node3D

#func _ready() -> void:
	#var ins:MeshInstance3D=$FloorPanelA8x4
	#var mesh:=ins.mesh
	#print(mesh.get("surface_0/name"))

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
		"maincolor": {
			name = "Main Color",
			type = "colorPalette",
			value = Color.WHITE,
			BDCC = true,
			basic = true,
		},
		"color": {
			name = "Color 1",
			type = "colorPalette",
			value = Color.WHITE,
			BDCC = true,
			basic = true,
		},
		"color2": {
			name = "Color 2",
			type = "colorPalette",
			value = Color.WHITE,
			BDCC = true,
			basic = true,
		},
		"color3": {
			name = "Color 3",
			type = "colorPalette",
			value = Color.WHITE,
			BDCC = true,
			basic = true,
		},
	}

func applyEditorOption(_id, _value):
	if(_id == "roughness"):
		setInstanceShaderParameter("roughness_mult", _value)
	if(_id == "maincolor"):
		setInstanceShaderParameter("trim_color_base", _value)
	if(_id == "color"):
		setInstanceShaderParameter("trim_color_main", _value)
	if(_id == "color2"):
		setInstanceShaderParameter("trim_color_second", _value)
	if(_id == "color3"):
		setInstanceShaderParameter("trim_color_third", _value)

func getMeshes() -> Array:
	var result:Array = []
	for child in get_children():
		if(child is MeshInstance3D):
			result.append(child)
	return result

func setInstanceShaderParameter(_id:String, _value):
	for mesh in getMeshes():
		mesh.set_instance_shader_parameter(_id, _value)
