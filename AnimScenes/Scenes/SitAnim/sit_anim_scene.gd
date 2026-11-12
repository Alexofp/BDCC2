extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var stand_spot: Marker3D = %StandSpot

func _init() -> void:
	id = "sit_anim"
	
	animLibs = ["BasicAnims"]

func setupScene() -> void:
	addSeat("dom", sit_spot)
	
	addState("sit", {
		dom = "BasicAnims/Sit",
	})
	
	setStartState("sit")
	
