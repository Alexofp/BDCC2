extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2

func _init() -> void:
	id = "start_sex"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	
	addAnimLibrary("sexStart", "res://Anims/Raw/SexStartAnims.glb")
	
	addState("start", {
		dom = "sexStart/SexStart_1",
		sub = "sexStart/SexStart_2",
	})
	addState("cuddle", {
		dom = "sexStart/Cuddle_1",
		sub = "sexStart/Cuddle_2",
	})
	
	connectStates("start", "cuddle", 0.0)
	
	setStartState("start")
	
func onPlayState(_state:String, _args:Dictionary):
	super.onPlayState(_state, _args)
	if(_state == "cuddle"):
		alignPenisToPenisGuides("dom")
