extends SexTypeBase

const ROLE_DOM = "dom"
const ROLE_SUB = "sub"

var pose:String = ""

func _init() -> void:
	id = SexType.OnTheFloor

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_DOM, ROLE_SUB])
	pose = pickRandomPose()
	
func onStart():
	pass

func start_run():
	#playAnim(AnimScene.SexStart, "start", {dom=ROLE_DOM, sub=ROLE_SUB})
	playPoseOrAnim(pose, AnimScene.SexStart, "start", {dom=ROLE_DOM, sub=ROLE_SUB})

func start_actions(_role:String):
	if(!hasMainActivity()):
		if(canDoDomActions(_role)):
			addAction(action("Stop").delayCancel(0.5).do("stopSex").setScore(scoreSexStop(_role)))
			
			addPosePickActions("pickPose")

func start_do(_role:String, _id:String, _args:Array):
	if(_id == "stopSex"):
		getSexEngine().stopSex()

	if(_id == "pickPose"):
		pose = setPoseFromPickAction(pose, _args)
		doText(_role, "{"+_role+".You} {"+_role+".youVerb switch|switches} the pose!")
		doRun()
