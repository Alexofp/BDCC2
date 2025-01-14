@tool
extends Node3D
class_name PropBasic

@export var editorOptionsEasy:Dictionary = {
	"roughness": {type="roughness"},
	"colorbase": {type="color", value=Color("868686")},
	"color1": {type="color", value=Color("353535")},
	"color2": {type="color", value=Color("222222")},
	"color3": {type="color", value=Color("111111")},
}
@export var editorOptionsID:String = ""

func getEditorOptionsID() -> String:
	return editorOptionsID

func getEditorOptionsEasy() -> Dictionary:
	return editorOptionsEasy

func getEditorOptions() -> Dictionary:
	var result:Dictionary = {}
	var theSettings:Dictionary = getEditorOptionsEasy()
	for optionID in theSettings:
		var optionDict:Dictionary = theSettings[optionID]
		var type:String = optionDict["type"]
		if(type == "roughness"):
			result[optionID] = {
				name = ("Roughness" if !optionDict.has("name") else optionDict["name"]),
				type = "floatPresets",
				value = (0.5 if !optionDict.has("value") else optionDict["value"]),
				step = 0.01,
				presets = [
					0.0, 0.1, 0.25, 0.4, 0.5, 0.6, 0.75, 0.9, 1.0,
				],
			}
		elif(type == "uvscale"):
			result[optionID] = {
				name = ("Tile scale" if !optionDict.has("name") else optionDict["name"]),
				type = "floatPresets",
				value = (1.0 if !optionDict.has("value") else optionDict["value"]),
				step = 0.01,
				presets = [
					0.1, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 10.0,
				],
			}
		elif(type == "color"):
			result[optionID] = {
				name = (optionID if !optionDict.has("name") else optionDict["name"]),
				type = "colorPalette",
				value = (Color("868686") if !optionDict.has("value") else optionDict["value"]),
				palette = ([] if !optionDict.has("palette") else optionDict["palette"]),
				BDCC = true,
				basic = true,
			}
		elif(type == "colorLight"):
			result[optionID] = {
				name = (optionID if !optionDict.has("name") else optionDict["name"]),
				type = "colorPalette",
				value = (Color("fffea4") if !optionDict.has("value") else optionDict["value"]),
				palette = ([] if !optionDict.has("palette") else optionDict["palette"]),
				light = true,
			}
		elif(type == "matpicker"):
			result[optionID] = {
				name = ("Material" if !optionDict.has("name") else optionDict["name"]),
				type = "selector",
				value = optionDict["value"] if optionDict.has("value") else (optionDict["values"][0] if !(optionDict["values"][0] is Array) else optionDict["values"][0][0]),
				values = optionDict["values"],
			}
		
	return result

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

func getMeshes() -> Array:
	var result:Array = []
	for child in get_children():
		if(child is MeshInstance3D):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func getMeshesSub(theNode:Node) -> Array:
	var result:Array = []
	for child in theNode.get_children():
		if(child is MeshInstance3D):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func setInstanceShaderParameter(_id:String, _value):
	for mesh in getMeshes():
		mesh.set_instance_shader_parameter(_id, _value)
