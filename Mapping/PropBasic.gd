extends Node3D
class_name PropBasic

var meshes:Array[GeometryInstance3D] = []
var meshesDirty:bool = true
#@export var roughness:float = 0.5
#@export var colorbase = Color("868686")
#@export var color1 = Color("353535")
#@export var color2 = Color("222222")
#@export var color3 = Color("111111")

#@export var editorOptionsEasy:Dictionary = {
	#"roughness": {type="roughness"},
	#"colorbase": {type="color", value=Color("868686")},
	#"color1": {type="color", value=Color("353535")},
	#"color2": {type="color", value=Color("222222")},
	#"color3": {type="color", value=Color("111111")},
#}
#@export var editorOptionsID:String = ""
signal onEditorValueChange(id, value)

const PROP_OPTIONS_FULL:Dictionary = {
	"roughness": {type="roughness"},
	"colorbase": {type="color"},
	"color1": {type="color"},
	"color2": {type="color"},
	"color3": {type="color"},
}
const PROP_OPTIONS_FULL_LIGHT:Dictionary = {
	"roughness": {type="roughness"},
	"colorbase": {type="color"},
	"color1": {type="color"},
	"color2": {type="color"},
	"color3": {type="colorLight"},
}
const EDITOR_OPTIONS_ID_NONE = ""
const EDITOR_OPTIONS_ID_WALL = "wall"
const EDITOR_OPTIONS_ID_BACKWALL = "backwall"
const EDITOR_OPTIONS_ID_TILE = "tile"
const EDITOR_OPTIONS_ID_STAIRS = "stairs"
const EDITOR_OPTIONS_ID_FANCYRAILING = "fancyrailing"
const EDITOR_OPTIONS_ID_FOUNDATION = "foundation"
const EDITOR_OPTIONS_ID_COLUMN = "column"
const EDITOR_OPTIONS_ID_DECAL = "decal"
const EDITOR_OPTIONS_ID_PIPE = "pipe"
const EDITOR_OPTIONS_ID_BIGFLOORSCI = "BigFloorSci"
const EDITOR_OPTIONS_ID_BIGFLOORTECH = "BigFloorTech"
const EDITOR_OPTIONS_ID_MIDDLEPIECECUTOUT = "MiddlePieceCutout"
const EDITOR_OPTIONS_ID_FLOORTILEWORLD = "floortileworld"
const EDITOR_OPTIONS_ID_CHAIR = "chair"
const EDITOR_OPTIONS_ID_DOORB = "doorb"
const EDITOR_OPTIONS_ID_WALLLIGHT = "walllight"
const EDITOR_OPTIONS_ID_SKYLINER = "skyliner"
const EDITOR_OPTIONS_ID_SLOPEDWINDOWBIG = "slopedwindowbig"
const EDITOR_OPTIONS_ID_SLOPEDWINDOWBIGSIDE = "slopedwindowbigside"

func _ready() -> void:
	applyAllEditorOptions()

func getEditorOptionsID() -> String:
	return ""

func getEditorOptionsEasy() -> Dictionary:
	return {}

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
				#value = get(optionID),#(0.5 if !optionDict.has("value") else optionDict["value"]),
				step = 0.01,
				presets = [
					0.0, 0.1, 0.25, 0.4, 0.5, 0.6, 0.75, 0.9, 1.0,
				],
			}
		elif(type == "uvscale"):
			result[optionID] = {
				name = ("Tile scale" if !optionDict.has("name") else optionDict["name"]),
				type = "floatPresets",
				#value = get(optionID),#(1.0 if !optionDict.has("value") else optionDict["value"]),
				step = 0.01,
				presets = [
					0.1, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 10.0,
				],
			}
		elif(type == "color"):
			result[optionID] = {
				name = (optionID if !optionDict.has("name") else optionDict["name"]),
				type = "colorPalette",
				#value = get(optionID),#(Color("868686") if !optionDict.has("value") else optionDict["value"]),
				palette = ([] if !optionDict.has("palette") else optionDict["palette"]),
				BDCC = true,
				basic = true,
			}
		elif(type == "colorLight"):
			result[optionID] = {
				name = (optionID if !optionDict.has("name") else optionDict["name"]),
				type = "colorPalette",
				#value = get(optionID),#(Color("fffea4") if !optionDict.has("value") else optionDict["value"]),
				palette = ([] if !optionDict.has("palette") else optionDict["palette"]),
				light = true,
			}
		elif(type == "matpicker"):
			result[optionID] = {
				name = ("Material" if !optionDict.has("name") else optionDict["name"]),
				type = "selector",
				#value = get(optionID),#optionDict["value"] if optionDict.has("value") else (optionDict["values"][0] if !(optionDict["values"][0] is Array) else optionDict["values"][0][0]),
				values = optionDict["values"],
			}
		
	return result

func getEditorOptionsWithValues() -> Dictionary:
	var result := getEditorOptions()
	for optionID in result:
		result[optionID]["value"] = getEditorOption(optionID)
	return result
	
func applyAllEditorOptions():
	var theOptions := getEditorOptions()
	for theOptionID in theOptions:
		applyEditorOption(theOptionID, getEditorOption(theOptionID))

func setEditorOption(_id:String, _value:Variant):
	set(_id, _value)
	applyEditorOption(_id, _value)

func notifySetEditorValue(_id:String, _value:Variant):
	onEditorValueChange.emit(_id, _value)
	applyEditorOption(_id, _value)

func getEditorOption(_id:String) -> Variant:
	return get(_id)

func applyEditorOption(_id, _value):
	match _id:
		"roughness":
			setInstanceShaderParameter("roughness_mult", _value)
		"colorbase":
			setInstanceShaderParameter("trim_color_base", _value)
		"color1":
			setInstanceShaderParameter("trim_color_main", _value)
		"color2":
			setInstanceShaderParameter("trim_color_second", _value)
		"color3":
			setInstanceShaderParameter("trim_color_third", _value)
		"uvShift":
			setInstanceShaderParameter("uvShift", _value)

func getMeshes() -> Array[GeometryInstance3D]:
	if(!meshesDirty):
		return meshes
	var result:Array[GeometryInstance3D] = []
	for child in get_children():
		if(child is PropBasic): # Another prop has started
			continue
		if(child is MeshInstance3D):
			result.append(child)
		result.append_array(getMeshesSub(child))
	meshes = result
	meshesDirty = false
	return result

func getMeshesSub(theNode:Node) -> Array[GeometryInstance3D]:
	var result:Array[GeometryInstance3D] = []
	for child in theNode.get_children():
		if(child is PropBasic): # Another prop has started
			continue
		if(child is MeshInstance3D):
			result.append(child)
		result.append_array(getMeshesSub(child))
	return result

func setInstanceShaderParameter(_id:String, _value):
	for mesh in getMeshes():
		mesh.set_instance_shader_parameter(_id, _value)
