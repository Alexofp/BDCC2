extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var stand_spot: Marker3D = %StandSpot

func setupScene() -> void:
	addSeat("dom", sit_spot)
	
	addAnimLibrary("basic", "res://Anims/Raw/BasicAnims.glb")
	
	addState("sit", {
		dom = "basic/Sit",
	})
	
	setStartState("sit")
	
	updateAllAnimTrees()
