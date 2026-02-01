extends AIActionBase

func _init() -> void:
	id = "Wander"

func start(_args:Array):
	pass

func think():
	if(hasSubAction()):
		return
	var theWanderArea := GI.world.getRandomWanderArea(getPos())
	if(!theWanderArea):
		return
	
	startSubAction("GoTo", [theWanderArea.getRandomSpot()], "go")

func onSubActionResult(_tag:String, _status:int, _result:Array):
	if(_tag == "go"):
		#startSubAction("Wait", [1.0])
		pushTimer(1.0)
		pushEvent("doEnd")

func onSubEvent(_eventID:String, _args:Array):
	if(_eventID == "doEnd"):
		completeAction()
