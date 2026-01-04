extends SexPoseBase

func _init() -> void:
	id = "StocksStartStanding"
	sexTypeID = SexType.InStocks
	sexActivityID = SexType.InStocks

	anim = AnimScene.StocksStart

func getVisibleName() -> String:
	return "Standing"

func getState(_stateRaw:String) -> String:
	if(_stateRaw == "normal"):
		return "standing"
	
	return _stateRaw
