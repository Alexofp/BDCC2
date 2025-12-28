extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var stand_spot: Marker3D = %StandSpot

func _init() -> void:
	id = "stocks"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	
	addAnimLibrary("stocks", "res://Anims/Raw/StocksAnims.glb")
	
	addState("bent", {
		dom = "stocks/StocksBent",
	})
	addState("standing", {
		dom = "stocks/StocksStanding",
	})
	
	connectStates("bent", "standing")
	
	setStartState("bent")
	
