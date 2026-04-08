extends SexTypeBase

const ROLE_DOM = "dom"
const ROLE_SUB = "sub"

func _init() -> void:
	id = SexType.InStocks
	poseSupport = true

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_DOM, ROLE_SUB])
	pickRandomPose()
	
func onStart():
	pass

func onSexEnd():
	if(!Network.isServer()):
		return
	var theEngine := getSexEngine()
	if(!theEngine):
		return
	var theProp := theEngine.getProp("stocks")
	if(!theProp):
		return
	var theSub := getRolePawn(ROLE_SUB)
	if(!theSub):
		return
	var theHandler = theProp.getStocksHandler()
	theHandler.setSitter("dom", theSub)

func start_run():
	playAnim(AnimScene.StocksStart, "normal", {dom=ROLE_DOM, sub=ROLE_SUB})

func start_actions(_role:String):
	if(!hasMainActivity()):
		if(canDoDomActions(_role)):
			addAction(action("Stop").delayCancel(0.5).do("stopSex").setScore(scoreSexStop(_role)))

func start_do(_role:String, _id:String, _args:Array):
	if(_id == "stopSex"):
		getSexEngine().stopSex()

func canTweakPosition() -> bool:
	return false
