extends Node3D
class_name ShaderPrecompScreen

const COMPILE_IN_DEBUG = false
const COMPILE_IN_RELEASE = true

const BASIC_MATERIALS = [ # Won't be used for skeletal meshes 100%
	"res://Mesh/Materials/Floors/BlackTiles.tres",
	"res://Mesh/Materials/Floors/ConcreteFloor.tres",
	"res://Mesh/Materials/Floors/ConcreteTiles.tres",
	"res://Mesh/Materials/Floors/FabricTiles.tres",
	"res://Mesh/Materials/Floors/HexFloor.tres",
	"res://Mesh/Materials/Floors/RustyMetal.tres",
	
	"res://Mesh/Materials/GlassMat.tres",
	"res://Mesh/Materials/MyBigTrim.tres",
	"res://Mesh/Materials/MyBigTrimSmart.tres",
	"res://Mesh/Materials/MyDecalTrim.tres",
	"res://Mesh/Materials/MyFloorTrimSmart.tres",
	"res://Mesh/Materials/MyPipeMaterial.tres",
	"res://Mesh/Materials/MyTrimSmart.tres",
	
]

const MATERIALS = [
	"res://Mesh/Clothing/InmateCollar/InmateCollatMat.tres",
	"res://Mesh/Clothing/InmateCuffs/InmateCuffMat.tres",
	"res://Mesh/Clothing/InmateTop/inmateTopMat.tres",
	"res://Mesh/Clothing/PlainBra/plain_bra_fem.tres",
	"res://Mesh/Clothing/PlainPanties/plain_panties_fem.tres",
	"res://Mesh/Clothing/Shorts/shortsMat.tres",
	"res://Mesh/Cum/NurbsCum/CumNurbsMat.tres",
	
	"res://Mesh/Materials/MyLeatherTrimSmart.tres",
	"res://Mesh/Materials/PreviewMat.tres",
	
	"res://Mesh/Parts/Body/FeminineBody/Materials/ClawMat.tres",
	"res://Mesh/Parts/Body/FeminineBody/Materials/GenitalsMat.tres",
	"res://Mesh/Parts/Body/FeminineBody/Materials/HindPawPadsMat.tres",
	"res://Mesh/Parts/Body/FeminineBody/Materials/NipplesMat.tres",
	"res://Mesh/Parts/Body/FeminineBody/Materials/PubicHairMat.tres",
	"res://Mesh/Parts/Body/FeminineBody/Materials/SpadeMat.tres",
	"res://Mesh/Parts/Body/FeminineBody/Materials/ToeClawMat.tres",
	"res://Mesh/Parts/Body/FeminineBody/BodyMatTest.tres",
	"res://Mesh/Parts/Body/FeminineBody/FurBodySmartMat.tres",
	"res://Mesh/Parts/Body/FeminineBody/SkinBodySmartMat.tres",
	"res://Mesh/Parts/Ear/FluffyEar/FelineEarMat.tres",
	"res://Mesh/Parts/Ear/FluffyEar/FluffMat.tres",
	"res://Mesh/Parts/Ear/FluffyEar/TasselsMat.tres",
	"res://Mesh/Parts/Head/CanineHead/MouthMat.tres",
	"res://Mesh/Parts/Head/FelineHead/HeadMat.tres",
	"res://Mesh/Parts/Head/FelineHead/MouthMat.tres",
	"res://Mesh/Parts/Head/HumanFeminine/Materials/HumanHeadMat.tres",
	"res://Mesh/Parts/Head/HumanFeminine/Materials/HumanMouthMat.tres",
	"res://Mesh/Parts/Horn/Horn1/HornMat.tres",
	"res://Mesh/Parts/Penis/CaninePenis/PenisBallsFurMat.tres",
	"res://Mesh/Parts/Penis/CaninePenis/ShaftMat.tres",
	"res://Mesh/Parts/Penis/CaninePenis/TuftMat.tres",
	"res://Mesh/Parts/SharedMaterials/EyeBrowsMat.tres",
	"res://Mesh/Parts/SharedMaterials/EyelashesBigMat.tres",
	"res://Mesh/Parts/SharedMaterials/EyelashesMat.tres",
	"res://Mesh/Parts/SharedMaterials/EyeMat.tres",
	"res://Mesh/Parts/SharedMaterials/HairMat.tres",
	"res://Mesh/Parts/SharedMaterials/PawPadsMat.tres",
	"res://Mesh/Parts/SharedMaterials/PiercingsMat.tres",
	"res://Mesh/Parts/SharedMaterials/PiercingsMatOLD.tres", #Could be removed
	"res://Mesh/Parts/SharedMaterials/RubberBandMat.tres",
	"res://Mesh/Parts/Tail/DragonTail/DragonTailMat.tres",
	"res://Mesh/Parts/Tail/FluffyTail/TailMat.tres",
	"res://Mesh/Parts/Tail/LongTail/TailMat.tres",
	"res://Mesh/SharedMaterials/Hair/HairMat.tres",
	"res://Mesh/SharedMaterials/Preview/previewDollPartMat.tres",
	"res://Mesh/Util/SimpleChainMat.tres",
	"res://Mesh/Parts/Hair/LongHairBow/BowMat.tres",
	
]
const SCENES = [
	"res://Mapping/Decals/DecalArrow2White.tscn",
]

static var didPrecomp:bool = false
#@onready var feminine_body: Node3D = $FeminineBody

@onready var CUBES:Array[MeshInstance3D] = [
	$NormalCube,
	$RiggedShapekeyCube2/RiggedShapekeyCube/Skeleton3D/Cube,
	$RiggedCube2/RiggedCube/Skeleton3D/Cube,
]
@onready var normal_cube: MeshInstance3D = $NormalCube

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
	LoadingScreen.setText("Loading..")
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	var totalCount:int = MATERIALS.size() + SCENES.size() + BASIC_MATERIALS.size()
	var current:int = 0
	
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
	
	for scenePath in SCENES:
		current += 1
		updateProgress(current, totalCount)
		
		var theScene:PackedScene = load(scenePath)
		if(!theScene):
			Log.Printerr("[Precompilation screen] Scene is not found: '"+str(scenePath)+"'")
		else:
			var theNode = theScene.instantiate()
			add_child(theNode)
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			theNode.queue_free()

func updateProgress(current:int, total:int):
	if(total <= 0):
		return
	var percent:float = float(current) / float(total)
	var percentText:String = str(int(round(percent*100.0)))
	LoadingScreen.setText("Loading.. "+percentText+"%")

func setMat(_mat:Material):
	for mesh in CUBES:
		mesh.set_surface_override_material(0, _mat)

func setMatBasic(_mat:Material):
	normal_cube.set_surface_override_material(0, _mat)

func shouldCompileShaders() -> bool:
	if("--skipShaderCompilation" in OS.get_cmdline_user_args()):
		return false
	elif("--forceShaderCompilation" in OS.get_cmdline_user_args()):
		return true
	if(OS.is_debug_build()):
		return COMPILE_IN_DEBUG
	return COMPILE_IN_RELEASE
