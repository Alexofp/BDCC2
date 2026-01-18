extends Node3D
class_name ShaderPrecompScreen

const COMPILE_IN_DEBUG = false
const COMPILE_IN_RELEASE = true
const ADD_TENMATSPLANE = true
const ADD_ONE_GIANT_PLANE = true

const SHADERS = [
	"res://addons/godot-polyliner/shaders/parallax/raymarch_chain.gdshader",
]

const BASIC_MATERIALS = [ # Won't be used for skeletal meshes 100%
	"res://Mesh/Materials/GlassMat.tres",	
]

const MATERIALS = [
	"res://Mesh/Clothing/InmateCollar/InmateCollatMat.tres",
	"res://Mesh/Clothing/InmateCuffs/InmateCuffMat.tres",
	"res://Mesh/Cum/NurbsCum/CumNurbsMat.tres",
	"res://Mesh/Materials/PreviewMat.tres",
	"res://Mesh/Parts/Ear/FluffyEar/FluffMat.tres",
	
]
const SCENES = [
	#"res://UI/ShaderPrecompScreen/precomp_doll.tscn",
]

static var didPrecomp:bool = false
#@onready var feminine_body: Node3D = $FeminineBody

@onready var CUBES:Array[MeshInstance3D] = [
	$NormalCube,
	$RiggedShapekeyCube2/RiggedShapekeyCube/Skeleton3D/Cube,
	$RiggedCube2/RiggedCube/Skeleton3D/Cube,
]
@onready var normal_cube: MeshInstance3D = $NormalCube

const TEN_MATS_PLANE = preload("res://UI/ShaderPrecompScreen/TenMatsPlane.tscn")
var curTenMatIndx:int = 0
var curTenMat:Node3D
const TEN_MATS_PLANE_RIGGED = preload("res://UI/ShaderPrecompScreen/TenMatsPlaneRigged.tscn")
var curTenMatRiggedIndx:int = 0
var curTenMatRigged:Node3D
const UNIQUE_SHADER_PRECOMP_PLANE = preload("res://UI/ShaderPrecompScreen/Util/unique_shader_precomp_plane.tscn")

func _ready():
	doStuff()
	LoadingScreen.startLoad()

func doStuff():
	didPrecomp = true
	var _theCurrentScenePath:String = get_tree().root.scene_file_path
	
	if(shouldCompileShaders()):
		await compileShaders()
	elif(ADD_ONE_GIANT_PLANE):
		await addBigPlane()
	
	#get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	#get_tree().change_scene_to_file("res://Game/Sandbox/Sandbox.tscn")
	if(GlobalRegistry.beganInit):
		if(!GlobalRegistry.finishedInit):
			LoadingScreen.setText("Loading..")
			await GlobalRegistry.initialized
	
	GM.startMainMenu()
	LoadingScreen.finishLoad()
	#get_tree().change_scene_to_file(_theCurrentScenePath)

func addBigPlane():
	GlobalRegistry.shaderTracker.setShouldCheck(false)
	LoadingScreen.setText("Loading..")
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var theBigPlane:Node3D = load("res://UI/ShaderPrecompScreen/GiantShaderPrecompPlane.tscn").instantiate()
	theBigPlane.visible = false
	GlobalRegistry.add_child(theBigPlane)
	GlobalRegistry.shaderTracker.setShouldCheck(true)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw

func compileShaders():
	GlobalRegistry.shaderTracker.setShouldCheck(false)
	LoadingScreen.setText("Loading..")
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	var allShaders := GiantShaderPrecompPlane.getShaderPathsByType(GiantShaderPrecompPlane.SHADERS_FOLDER)
	var totS:int = 0
	for _shaderType in allShaders:
		totS += allShaders[_shaderType].size()
	
	var allMats := GiantShaderPrecompPlane.getMaterialPathsByType(GiantShaderPrecompPlane.MATERIALS_FOLDER)
	for _shaderType in allMats:
		totS += allMats[_shaderType].size()
	
	var totalCount:int = MATERIALS.size() + SCENES.size() + BASIC_MATERIALS.size() + totS + SHADERS.size()
	var current:int = 0
	
	for shaderPath in allShaders[GiantShaderPrecompPlane.SHADER_BOTH]:
		current += 1
		updateProgress(current, totalCount)
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		pushMatToTensPlane(shaderMat)
		pushMatToTensPlaneRigged(shaderMat)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
	for shaderPath in allShaders[GiantShaderPrecompPlane.SHADER_SKELETON]:
		current += 1
		updateProgress(current, totalCount)
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		pushMatToTensPlaneRigged(shaderMat)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
	for shaderPath in allShaders[GiantShaderPrecompPlane.SHADER_STATIC]:
		current += 1
		updateProgress(current, totalCount)
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		pushMatToTensPlane(shaderMat)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
	for shaderPath in allShaders[GiantShaderPrecompPlane.SHADER_UNIQUE]:
		current += 1
		updateProgress(current, totalCount)
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		pushMatToUniquePlane(shaderMat)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		
	for matPath in allMats[GiantShaderPrecompPlane.SHADER_BOTH]:
		current += 1
		updateProgress(current, totalCount)
		var theMat:Material = load(matPath)
		pushMatToTensPlane(theMat)
		pushMatToTensPlaneRigged(theMat)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
	for matPath in allMats[GiantShaderPrecompPlane.SHADER_SKELETON]:
		current += 1
		updateProgress(current, totalCount)
		pushMatToTensPlaneRigged(load(matPath))
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
	for matPath in allMats[GiantShaderPrecompPlane.SHADER_STATIC]:
		current += 1
		updateProgress(current, totalCount)
		pushMatToTensPlane(load(matPath))
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
	for matPath in allMats[GiantShaderPrecompPlane.SHADER_UNIQUE]:
		current += 1
		updateProgress(current, totalCount)
		pushMatToUniquePlane(load(matPath))
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
	for theMat in allMats[GiantShaderPrecompPlane.SHADER_PARTICLE]:
		var newGpuParticles:GPUParticles3D = GPUParticles3D.new()
		newGpuParticles.visible = false
		newGpuParticles.process_material = load(theMat)
		newGpuParticles.emitting = false
		add_child(newGpuParticles, true)
		newGpuParticles.owner = self
	
	#for shaderPath in (hairShaderPaths+shaderPaths+SHADERS):
		#current += 1
		#updateProgress(current, totalCount)
		#var shaderMat:ShaderMaterial = ShaderMaterial.new()
		#shaderMat.shader = load(shaderPath)
		#setMat(shaderMat)
		#await RenderingServer.frame_post_draw
		#await RenderingServer.frame_post_draw
	
	for scenePath in SCENES:
		current += 1
		updateProgress(current, totalCount)
		
		var theScene:PackedScene = load(scenePath)
		if(!theScene):
			Log.Printerr("[Precompilation screen] Scene is not found: '"+str(scenePath)+"'")
		else:
			var theNode = theScene.instantiate()
			theNode.visible = false
			add_child(theNode)
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			theNode.queue_free()
	
	for matPath in BASIC_MATERIALS:
		current += 1
		updateProgress(current, totalCount)
		
		var theMat:Material = load(matPath)
		if(!theMat):
			Log.Printerr("[Precompilation screen] Material is not found: '"+str(matPath)+"'")
		else:
			setMatBasic(load(matPath))
		
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		
	for matPath in MATERIALS:
		current += 1
		updateProgress(current, totalCount)
		
		var theMat:Material = load(matPath)
		if(!theMat):
			Log.Printerr("[Precompilation screen] Material is not found: '"+str(matPath)+"'")
		else:
			setMat(load(matPath))
		
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
	
	GlobalRegistry.shaderTracker.setShouldCheck(true)

func pushMatToUniquePlane(_mat:Material):
	var newPlane:MeshInstance3D = UNIQUE_SHADER_PRECOMP_PLANE.instantiate()
	newPlane.visible = false
	GlobalRegistry.add_child(newPlane, true)
	#newPlane.owner = self
	#set_editable_instance(newPlane, true)
	newPlane.set_surface_override_material(0, _mat)

func updateProgress(current:int, total:int):
	if(total <= 0):
		return
	var percent:float = float(current) / float(total)
	var percentText:String = str(int(round(percent*100.0)))
	LoadingScreen.setText("Loading.. "+percentText+"%")

func setMat(_mat:Material):
	pushMatToTensPlane(_mat)
	#pushMatToTensPlaneRigged(_mat)
	#for mesh in CUBES:
	#	mesh.set_surface_override_material(0, _mat)
	
func pushMatToTensPlane(_mat:Material):
	if(!ADD_TENMATSPLANE):
		return
	if(!curTenMat):
		curTenMat = TEN_MATS_PLANE.instantiate()
		curTenMat.visible = false
		GlobalRegistry.add_child(curTenMat, true)
		#print("NEW 10 MAT")
	curTenMat.get_node("Plane").set_surface_override_material(curTenMatIndx, _mat)
	curTenMatIndx += 1
	if(curTenMatIndx >= 10):
		curTenMatIndx = 0
		curTenMat = null
	
func pushMatToTensPlaneRigged(_mat:Material):
	if(!ADD_TENMATSPLANE):
		return
	if(!curTenMatRigged):
		curTenMatRigged = TEN_MATS_PLANE_RIGGED.instantiate()
		curTenMatRigged.visible = false
		GlobalRegistry.add_child(curTenMatRigged, true)
		#print("NEW 10 MAT")
	curTenMatRigged.get_node("PlaneRig/Skeleton3D/Plane").set_surface_override_material(curTenMatRiggedIndx, _mat)
	curTenMatRigged.get_node("PlaneRig/Skeleton3D/PlaneShapes").set_surface_override_material(curTenMatRiggedIndx, _mat)
	curTenMatRiggedIndx += 1
	if(curTenMatRiggedIndx >= 10):
		curTenMatRiggedIndx = 0
		curTenMatRigged = null

func setMatBasic(_mat:Material):
	pushMatToTensPlane(_mat)
	#pushMatToTensPlaneRigged(_mat)
	normal_cube.set_surface_override_material(0, _mat)

func shouldCompileShaders() -> bool:
	if("--skipShaderCompilation" in OS.get_cmdline_user_args()):
		return false
	elif("--forceShaderCompilation" in OS.get_cmdline_user_args()):
		return true
	if(OS.is_debug_build()):
		return COMPILE_IN_DEBUG
	return COMPILE_IN_RELEASE
