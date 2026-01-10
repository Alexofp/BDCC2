@tool
extends Node3D

const TEN_MATS_PLANE = preload("res://UI/ShaderPrecompScreen/TenMatsPlane.tscn")
var curTenMatIndx:int = 0
var curTenMat:Node3D
const TEN_MATS_PLANE_RIGGED = preload("res://UI/ShaderPrecompScreen/TenMatsPlaneRigged.tscn")
var curTenMatRiggedIndx:int = 0
var curTenMatRigged:Node3D

@export_tool_button("DoTheThing", "Callable") var makePlaneAction = makePlane

func makePlane():
	Util.delete_children(self)
	
	var hairShaderPaths:Array[String] = Util.getResourcesFromFolderRecursive("res://Mesh/SharedMaterials/Hair/Shaders/", ["gdshader"])
	var shaderPaths:Array[String] = Util.getResourcesFromFolderRecursive("res://Mesh/Materials/Shaders/", ["gdshader"])
	
	var allPaths:Array[String] = hairShaderPaths + shaderPaths
	
	for shaderPath in allPaths:
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		
		pushMatToTensPlane(shaderMat)
		pushMatToTensPlaneRigged(shaderMat)
	
func pushMatToTensPlane(_mat:Material):
	#if(!ADD_TENMATSPLANE):
	#	return
	if(!curTenMat):
		curTenMat = TEN_MATS_PLANE.instantiate()
		curTenMat.visible = false
		add_child(curTenMat, true)
		curTenMat.owner = self
		set_editable_instance(curTenMat, true)
		#print("NEW 10 MAT")
	curTenMat.get_node("Plane").set_surface_override_material(curTenMatIndx, _mat)
	curTenMatIndx += 1
	if(curTenMatIndx >= 10):
		curTenMatIndx = 0
		curTenMat = null
	
func pushMatToTensPlaneRigged(_mat:Material):
	#if(!ADD_TENMATSPLANE):
	#	return
	if(!curTenMatRigged):
		curTenMatRigged = TEN_MATS_PLANE_RIGGED.instantiate()
		curTenMatRigged.visible = false
		add_child(curTenMatRigged, true)
		curTenMatRigged.owner = self
		set_editable_instance(curTenMatRigged, true)
		#print("NEW 10 MAT")
	curTenMatRigged.get_node("PlaneRig/Skeleton3D/Plane").set_surface_override_material(curTenMatRiggedIndx, _mat)
	curTenMatRiggedIndx += 1
	if(curTenMatRiggedIndx >= 10):
		curTenMatRiggedIndx = 0
		curTenMatRigged = null
