extends Node3D
class_name ShaderPrecompScreen

const COMPILE_IN_DEBUG = false
const COMPILE_IN_RELEASE = true
const ADD_TENMATSPLANE = true

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
	#"res://Mapping/Decals/DecalArrow2White.tscn",
	"res://UI/ShaderPrecompScreen/precomp_doll.tscn",
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

func _ready():
	doStuff()
	LoadingScreen.startLoad()

func doStuff():
	didPrecomp = true
	var _theCurrentScenePath:String = get_tree().root.scene_file_path
	
	if(shouldCompileShaders()):
		await compileShaders()
	
	#get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	#get_tree().change_scene_to_file("res://Game/Sandbox/Sandbox.tscn")
	if(GlobalRegistry.beganInit):
		if(!GlobalRegistry.finishedInit):
			LoadingScreen.setText("Loading..")
			await GlobalRegistry.initialized
	
	GM.startMainMenu()
	LoadingScreen.finishLoad()
	#get_tree().change_scene_to_file(_theCurrentScenePath)

func compileShaders():
	GlobalRegistry.shaderTracker.setShouldCheck(false)
	LoadingScreen.setText("Loading..")
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	var hairShaderPaths:Array[String] = Util.getResourcesFromFolderRecursive("res://Mesh/SharedMaterials/Hair/Shaders/", ["gdshader"])
	
	
	var shaderPaths:Array[String] = Util.getResourcesFromFolderRecursive("res://Mesh/Materials/Shaders/", ["gdshader"])
	
	var totalCount:int = MATERIALS.size() + SCENES.size() + BASIC_MATERIALS.size() + shaderPaths.size() + hairShaderPaths.size() + SHADERS.size()
	var current:int = 0
	
	for shaderPath in (hairShaderPaths+shaderPaths+SHADERS):
		current += 1
		updateProgress(current, totalCount)
		var shaderMat:ShaderMaterial = ShaderMaterial.new()
		shaderMat.shader = load(shaderPath)
		setMat(shaderMat)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
	
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

func updateProgress(current:int, total:int):
	if(total <= 0):
		return
	var percent:float = float(current) / float(total)
	var percentText:String = str(int(round(percent*100.0)))
	LoadingScreen.setText("Loading.. "+percentText+"%")

func setMat(_mat:Material):
	pushMatToTensPlane(_mat)
	#pushMatToTensPlaneRigged(_mat)
	for mesh in CUBES:
		mesh.set_surface_override_material(0, _mat)
	
func pushMatToTensPlane(_mat:Material):
	if(!ADD_TENMATSPLANE):
		return
	if(!curTenMat):
		curTenMat = TEN_MATS_PLANE.instantiate()
		curTenMat.visible = false
		GlobalRegistry.add_child(curTenMat)
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
		GlobalRegistry.add_child(curTenMatRigged)
		#print("NEW 10 MAT")
	curTenMatRigged.get_node("PlaneRig/Skeleton3D/Plane").set_surface_override_material(curTenMatRiggedIndx, _mat)
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
