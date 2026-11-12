extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var stand_spot: Marker3D = %StandSpot
@onready var prop_spot: PropSpot = %PropSpot

func _init() -> void:
	id = "stocks"
	
	propAnimLibs = {
		"stocks": ["StocksSolo_Stocks"],
	}
	animLibs = ["StocksSolo_Doll"]

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addPropSpot("stocks", prop_spot)
	
	addState("bent", {
		dom = "StocksSolo_Doll/Normal_2",
		stocks = "StocksSolo_Stocks/Stocks_Normal",
	})
	addState("standing", {
		dom = "StocksSolo_Doll/Standing_2",
		stocks = "StocksSolo_Stocks/Stocks_Standing",
	})
	
	connectStates("bent", "standing")
	
	setStartState("bent")
	
