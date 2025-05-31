extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	
	addAnimLibrary("sexStart", "res://Anims/Raw/SexStartAnims.glb")
	
	addState("start", {
		dom = "sexStart/SexStart_1",
		sub = "sexStart/SexStart_2",
	}, {
		CONF_BASESPEED: 1.0,
	})
	
	setStartState("start")
	
	updateAllAnimTrees()
