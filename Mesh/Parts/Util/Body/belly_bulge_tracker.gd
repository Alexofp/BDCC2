extends Node
class_name BellyBulgeTracker

@export var dollPart:DollPart

var cachedValue:float = 0.0

func _process(_delta: float) -> void:
	if(!dollPart):
		return
	var theDoll:Doll = dollPart.getDoll()
	if(!theDoll):
		return
	
	var theBulgeVal:float = 0.0
	var hole1:DollOpenableHole = theDoll.getVaginaHoleNode()
	var hole2:DollOpenableHole = theDoll.getAnusHoleNode()
	
	if(hole1):
		theBulgeVal = max(theBulgeVal, hole1.getFactorDeep()-0.5)
	if(hole2):
		theBulgeVal = max(theBulgeVal, hole2.getFactorDeep()-0.5)
	theBulgeVal = min(theBulgeVal, 1.0)
	#print(theBulgeVal)
	
	#var aVal:float = hole1.getTipInVal()
	#if(aVal > 0.0):
	#	print(aVal)
	
	if(abs(theBulgeVal - cachedValue)<0.001):
		return
	cachedValue = theBulgeVal
	
	theDoll.holeData.bellyBump = clamp(theBulgeVal, 0.0, 1.0)
	theDoll.triggerHoleDataUpdate()
	
