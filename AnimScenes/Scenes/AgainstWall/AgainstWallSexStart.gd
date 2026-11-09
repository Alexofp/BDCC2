extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2

func _init() -> void:
	id = "AgainstWallSexStart"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	
	addAnimLibrary("AgainstWallSexStart", "res://Anims/Raw/AgainstWallSexStart.glb")
	
	addState("backLegUp", {
		dom = "AgainstWallSexStart/BackLegUp_1",
		sub = "AgainstWallSexStart/BackLegUp_2",
	})
	
	setStartState("backLegUp")
	
