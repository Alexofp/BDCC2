extends SexPoseBase

func _init() -> void:
	id = "StocksStartSex"
	sexTypeID = SexType.InStocks
	sexActivityID = SexType.InStocks

	anim = AnimScene.StocksSex

func getVisibleName() -> String:
	return "Sex (test)"

func getState(_stateRaw:String) -> String:
	#if(_stateRaw == "tease"):
	#	return "standing"
	
	#return _stateRaw
	return "tease"

func canBeUsed(_sexEngine:SexEngine, _sexActivity:SexEngineActivityBase) -> bool:
	return false # Disabled
