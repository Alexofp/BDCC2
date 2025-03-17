@tool
extends PropBasic

@export var floorMesh:MeshInstance3D

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"floormat": {type="matpicker", values = [
			["res://Mesh/Materials/Floors/HexFloor.tres", "Hex"],
			["res://Mesh/Materials/Floors/ConcreteFloor.tres", "Concrete"],
			["res://Mesh/Materials/Floors/BlackTiles.tres", "Black Tiles"],
			["res://Mesh/Materials/Floors/FabricTiles.tres", "Fabric Tiles"],
			["res://Mesh/Materials/Floors/RustyMetal.tres", "Rusty Metal"],
			["res://Mesh/Materials/Floors/ConcreteTiles.tres", "Concrete Tiles"],
		]},
		"roughness": {type="roughness"},
		"colorbase": {type="color", value=Color.WHITE},
		"uvscale": {type="uvscale"},
	}
	return theSettings

func applyEditorOption(_id, _value):
	if(_id == "floormat"):
		if(floorMesh != null):
			floorMesh.set_surface_override_material(0, load(_value))
	super.applyEditorOption(_id, _value)
	if(_id == "uvscale"):
		setInstanceShaderParameter("uv1_scale", _value)
