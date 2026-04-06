extends SexTypeBase

const ROLE_DOM = "dom"
const ROLE_SUB = "sub"

var pose:String = ""

func _init() -> void:
	id = SexType.InStocks

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_DOM, ROLE_SUB])
	pose = pickRandomPose()
	
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
	playPoseOrAnim(pose, AnimScene.StocksStart, "normal", {dom=ROLE_DOM, sub=ROLE_SUB})

func start_actions(_role:String):
	if(!hasMainActivity()):
		if(canDoDomActions(_role)):
			addAction(action("Stop").delayCancel(0.5).do("stopSex").setScore(scoreStop(_role)))
		
			addPosePickActions("pickPose")

func start_do(_role:String, _id:String, _args:Array):
	if(_id == "stopSex"):
		getSexEngine().stopSex()
	
	if(_id == "pickPose"):
		pose = setPoseFromPickAction(pose, _args)
		doText(_role, "{"+_role+".You} {"+_role+".youVerb switch|switches} the pose!")
		doRun()

func canTweakPosition() -> bool:
	return false
