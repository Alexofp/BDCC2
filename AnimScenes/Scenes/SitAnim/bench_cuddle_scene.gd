extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2

func _init() -> void:
	id = "bench_cuddle"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	
	addAnimLibrary("BenchCuddleAnim", "res://Anims/Raw/BenchCuddleAnim.glb")
	
	addState("cuddle", {
		dom = "BenchCuddleAnim/BenchCuddle_1",
		sub = "BenchCuddleAnim/BenchCuddle_2",
	})
	
	setStartState("cuddle")
	
