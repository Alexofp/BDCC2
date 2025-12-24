extends RefCounted
class_name LeashSettings

const TYPE_CHAIN = 0

var type:int = TYPE_CHAIN
var distance:float = 3.0
var breakDistance:float = 10.0
var sourcePull:float = 1.0 # How strong the pull of the source
var targetPull:float = 1.0 # How strong is the pull of the target

static func createSimple(_type:int = TYPE_CHAIN, _distance:float = 3.0, _breakDistance:float = 10.0) -> LeashSettings:
	var theSettings := LeashSettings.new()
	theSettings.type = _type
	theSettings.distance = _distance
	theSettings.breakDistance = _breakDistance
	return theSettings

func setSourcePull(_mult:float) -> LeashSettings:
	sourcePull = _mult
	return self
	
func setTargetPull(_mult:float) -> LeashSettings:
	targetPull = _mult
	return self

func saveData() -> Dictionary:
	return {
		distance = distance,
		breakDistance = breakDistance,
		sourcePull = sourcePull,
		targetPull = targetPull,
	}

func loadData(_data:Dictionary):
	distance = SAVE.loadVar(_data, "distance", 3.0)
	breakDistance = SAVE.loadVar(_data, "breakDistance", 10.0)
	sourcePull = SAVE.loadVar(_data, "sourcePull", 1.0)
	targetPull = SAVE.loadVar(_data, "targetPull", 1.0)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Float, distance,
		Bins.Float, breakDistance,
		Bins.Float, sourcePull,
		Bins.Float, targetPull,
	])

func loadNetworkData(_bins:Bins):
	_bins.loadStart()
	distance = _bins.readFloat()
	breakDistance = _bins.readFloat()
	sourcePull = _bins.readFloat()
	targetPull = _bins.readFloat()
	_bins.endLoad()
