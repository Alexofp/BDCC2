extends SexPoseBase

func _init() -> void:
	id = "StocksSexNormal"
	sexTypeID = SexType.InStocks
	sexActivityID = SexActivity.Sex

	anim = AnimScene.StocksSex

func getVisibleName() -> String:
	return "Bent forward"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "tease"):
	#	return "standing"
	
	return _stateRaw
	#return "tease"
