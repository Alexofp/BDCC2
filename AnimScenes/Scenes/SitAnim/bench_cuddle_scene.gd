extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	
	addAnimLibrary("cuddle", "res://Anims/Raw/BenchCuddleAnim.glb")
	
	addState("cuddle", {
		dom = "cuddle/BenchCuddle_1",
		sub = "cuddle/BenchCuddle_2",
	})
	
	setStartState("cuddle")
	
	updateAllAnimTrees()
