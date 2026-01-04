extends SexPoseBase

func _init() -> void:
	id = "StocksStartNormal"
	sexTypeID = SexType.InStocks
	sexActivityID = SexType.InStocks

	anim = AnimScene.StocksStart

func getVisibleName() -> String:
	return "Bent forward"

func getState(_stateRaw:String) -> String:
	if(_stateRaw == "normal"):
		return "normal"
	
	return _stateRaw
