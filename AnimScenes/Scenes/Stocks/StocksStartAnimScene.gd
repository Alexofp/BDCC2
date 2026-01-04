extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2
@onready var stand_spot: Marker3D = %StandSpot
@onready var prop_spot: PropSpot = %PropSpot

func _init() -> void:
	id = "stocksStart"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	addPropSpot("stocks", prop_spot)
	
	addAnimLibrary("stocks", "res://Anims/Raw/Stocks/StocksStart_Doll.glb")
	addPropAnimLibrary("stocks", "stocks", "res://Anims/Raw/Stocks/StocksStart_Stocks.glb")
	
	addState("normal", {
		dom = "stocks/Normal_1",
		sub = "stocks/Normal_2",
		stocks = "stocks/Normal_3",
	})
	addState("standing", {
		dom = "stocks/Standing_1",
		sub = "stocks/Standing_2",
		stocks = "stocks/Standing_3",
	})
	
	connectStates("normal", "standing", 0.3)
	
	setStartState("normal")
	
