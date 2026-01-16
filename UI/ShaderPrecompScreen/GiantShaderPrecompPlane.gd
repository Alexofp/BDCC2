@tool
extends Node3D
class_name GiantShaderPrecompPlane

const TEN_MATS_PLANE = preload("res://UI/ShaderPrecompScreen/TenMatsPlane.tscn")
var curTenMatIndx:int = 0
var curTenMat:Node3D
const TEN_MATS_PLANE_RIGGED = preload("res://UI/ShaderPrecompScreen/TenMatsPlaneRigged.tscn")
var curTenMatRiggedIndx:int = 0
var curTenMatRigged:Node3D
const UNIQUE_SHADER_PRECOMP_PLANE = preload("res://UI/ShaderPrecompScreen/Util/unique_shader_precomp_plane.tscn")

@export_tool_button("DoTheThing", "Callable") var makePlaneAction = makePlane

const SHADER_STATIC = 0
const SHADER_SKELETON = 1
const SHADER_BOTH = 2
const SHADER_UNIQUE = 3
const SHADER_PARTICLE = 4

const SHADER_FILETYPES:Array[String] = ["gdshader"]
const SHADERS_FOLDER:String = "res://Mesh/Shaders/"

const MATERIAL_FILETYPES:Array[String] = ["tres"]
const MATERIALS_FOLDER:String = "res://Mesh/MaterialsPrecompile/"

static func getShaderPathsByType(_folder:String) -> Dictionary[int, Array]:
	return getStuffPathsByType(_folder, SHADER_FILETYPES)

static func getMaterialPathsByType(_folder:String) -> Dictionary[int, Array]:
	return getStuffPathsByType(_folder, MATERIAL_FILETYPES)
	
static func getStuffPathsByType(_folder:String, _fileTypes:Array[String]) -> Dictionary[int, Array]:
	var result:Dictionary[int, Array]
	
	var staticPaths:Array[String]
	var skeletonPaths:Array[String]
	var bothPaths:Array[String]
	var uniquePaths:Array[String]
	var particlePaths:Array[String]
	
	var dir := DirAccess.open(_folder)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				var fullFolderPath:String = _folder.path_join(file_name)
				
				var theShaderPaths := Util.getResourcesFromFolderRecursive(fullFolderPath, _fileTypes)
				
				if(file_name.ends_with("_static")):
					staticPaths.append_array(theShaderPaths)
				elif(file_name.ends_with("_skeleton")):
					skeletonPaths.append_array(theShaderPaths)
				elif(file_name.ends_with("_all")):
					bothPaths.append_array(theShaderPaths)
				elif(file_name.ends_with("_unique")):
					uniquePaths.append_array(theShaderPaths)
				elif(file_name.ends_with("_particle")):
					particlePaths.append_array(theShaderPaths)
				else:
					bothPaths.append_array(theShaderPaths)
				
			#else:
			#	print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		Log.error("An error occurred when trying to access '"+_folder+"'")
	
	result[SHADER_STATIC] = staticPaths
	result[SHADER_SKELETON] = skeletonPaths
	result[SHADER_BOTH] = bothPaths
	result[SHADER_UNIQUE] = uniquePaths
	result[SHADER_PARTICLE] = particlePaths
	return result

func makePlane():
	Util.delete_children(self)
	
	var allShaders := getShaderPathsByType(SHADERS_FOLDER)
	
	for shaderPath in allShaders[SHADER_BOTH]:
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		pushMatToTensPlane(shaderMat)
		pushMatToTensPlaneRigged(shaderMat)
	for shaderPath in allShaders[SHADER_SKELETON]:
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		pushMatToTensPlaneRigged(shaderMat)
	for shaderPath in allShaders[SHADER_STATIC]:
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		pushMatToTensPlane(shaderMat)
	for shaderPath in allShaders[SHADER_UNIQUE]:
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		pushMatToUniquePlane(shaderMat)
		
	var allMats := getMaterialPathsByType(MATERIALS_FOLDER)
	for theMat in allMats[SHADER_BOTH]:
		var theMats:Material = load(theMat)
		pushMatToTensPlane(theMats)
		pushMatToTensPlaneRigged(theMats)
	for theMat in allMats[SHADER_SKELETON]:
		pushMatToTensPlaneRigged(load(theMat))
	for theMat in allMats[SHADER_STATIC]:
		pushMatToTensPlane(load(theMat))
	for theMat in allMats[SHADER_UNIQUE]:
		pushMatToUniquePlane(load(theMat))
	for theMat in allMats[SHADER_PARTICLE]:
		var newGpuParticles:GPUParticles3D = GPUParticles3D.new()
		newGpuParticles.visible = false
		newGpuParticles.process_material = load(theMat)
		newGpuParticles.emitting = false
		add_child(newGpuParticles, true)
		newGpuParticles.owner = self

func pushMatToUniquePlane(_mat:Material):
	var newPlane:MeshInstance3D = UNIQUE_SHADER_PRECOMP_PLANE.instantiate()
	newPlane.visible = false
	add_child(newPlane, true)
	newPlane.owner = self
	set_editable_instance(newPlane, true)
	newPlane.set_surface_override_material(0, _mat)

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
	curTenMatRigged.get_node("PlaneRig/Skeleton3D/PlaneShapes").set_surface_override_material(curTenMatRiggedIndx, _mat)
	curTenMatRiggedIndx += 1
	if(curTenMatRiggedIndx >= 10):
		curTenMatRiggedIndx = 0
		curTenMatRigged = null
