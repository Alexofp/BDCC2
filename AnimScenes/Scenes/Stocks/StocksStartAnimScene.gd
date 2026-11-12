extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2
@onready var stand_spot: Marker3D = %StandSpot
@onready var prop_spot: PropSpot = %PropSpot

func _init() -> void:
	id = "stocksStart"

	propAnimLibs = {
		"stocks": ["StocksStart_Stocks"],
	}
	animLibs = ["StocksStart_Doll"]

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	addPropSpot("stocks", prop_spot)
	
	addState("normal", {
		dom = "StocksStart_Doll/Normal_1",
		sub = "StocksStart_Doll/Normal_2",
		stocks = "StocksStart_Stocks/Normal_3",
	})
	addState("standing", {
		dom = "StocksStart_Doll/Standing_1",
		sub = "StocksStart_Doll/Standing_2",
		stocks = "StocksStart_Stocks/Standing_3",
	})
	
	connectStates("normal", "standing", 0.3)
	
	setStartState("normal")
	
