@tool
extends PropBasic

@export var floorMesh:MeshInstance3D

@export var flootMat:TilableFloorMat.Mats = TilableFloorMat.Mats.ConcreteTiles2:
	set(value):
		flootMat = value
		notifySetEditorValue("flootMat", value)
@export var floorMatCustom:String:
	set(value):
		floorMatCustom = value
		notifySetEditorValue("floorMatCustom", value)
@export var roughness:float = 0.5:
	set(value):
		roughness = value
		notifySetEditorValue("roughness", value)
@export var colorbase:Color = Color("868686"):
	set(value):
		colorbase = value
		notifySetEditorValue("colorbase", value)
@export var uvscale:float = 1.0:
	set(value):
		uvscale = value
		notifySetEditorValue("uvscale", value)

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_FLOORTILEWORLD

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"floormat": {type="matpicker", values = TilableFloorMat.getEditorValuesList()},
		"roughness": {type="roughness"},
		"colorbase": {type="color", value=Color.WHITE},
		"uvscale": {type="uvscale"},
	}
	return theSettings

func applyEditorOption(_id, _value):
	if(_id == "flootMat"):
		updateFloorMat()
	if(_id == "floorMatCustom"):
		updateFloorMat()
		#if(floorMesh != null):
		#	floorMesh.set_surface_override_material(0, load(_value))
	super.applyEditorOption(_id, _value)
	if(_id == "uvscale"):
		setInstanceShaderParameter("uv1_scale", _value)

func updateFloorMat():
	var theFinalMat:Material = null
	
	if(TilableFloorMat.MatToPath.has(flootMat)):
		theFinalMat = load(TilableFloorMat.MatToPath[flootMat])
	elif(!floorMatCustom.is_empty() && ResourceLoader.exists(floorMatCustom)):
		theFinalMat = load(floorMatCustom)
	
	if(floorMesh != null):
		floorMesh.set_surface_override_material(0, theFinalMat)
