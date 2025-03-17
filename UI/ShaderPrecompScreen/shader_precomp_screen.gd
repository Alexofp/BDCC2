extends Node3D
class_name ShaderPrecompScreen

static var didPrecomp:bool = false
@onready var feminine_body: Node3D = $FeminineBody

func _ready():
	doStuff()

func doStuff():
	didPrecomp = true
	var _theCurrentScenePath:String = get_tree().root.scene_file_path
	
	var stuffToMakeVisible:Array = [
		$FloorTile1x1,
		$Bench,
		$WallLight,
		$RiggedCube2/RiggedCube/Skeleton3D/Cube,
		$RiggedCube2/RiggedCube/Skeleton3D/Cube2,
		$RiggedCube2/RiggedCube/Skeleton3D/Cube3,
		$RiggedCube2/RiggedCube/Skeleton3D/Cube4,
		$RiggedCube2/RiggedCube/Skeleton3D/Cube5,
		$RiggedCube2/RiggedCube/Skeleton3D/Cube6,
		$RiggedCube2/RiggedCube/Skeleton3D/Cube7,
		$RiggedCube2/RiggedCube/Skeleton3D/Cube8,
		$RiggedCube2/RiggedCube/Skeleton3D/Cube9,
		#$MyHumanHead,
		feminine_body,
	]
	
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	for theNode in stuffToMakeVisible:
		theNode.visible = true
	
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		#await RenderingServer.frame_post_draw
		#await RenderingServer.frame_post_draw
	
	#get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	get_tree().change_scene_to_file("res://Game/Sandbox/Sandbox.tscn")
	#get_tree().change_scene_to_file(_theCurrentScenePath)
