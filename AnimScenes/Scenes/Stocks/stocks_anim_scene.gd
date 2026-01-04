extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var stand_spot: Marker3D = %StandSpot
@onready var prop_spot: PropSpot = %PropSpot

func _init() -> void:
	id = "stocks"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addPropSpot("stocks", prop_spot)
	
	addAnimLibrary("stocks", "res://Anims/Raw/Stocks/StocksSolo_Doll.glb")
	addPropAnimLibrary("stocks", "stocks", "res://Anims/Raw/Stocks/StocksSolo_Stocks.glb")
	
	addState("bent", {
		dom = "stocks/Normal_2",
		stocks = "stocks/Stocks_Normal",
	})
	addState("standing", {
		dom = "stocks/Standing_2",
		stocks = "stocks/Stocks_Standing",
	})
	
	connectStates("bent", "standing")
	
	setStartState("bent")
	
