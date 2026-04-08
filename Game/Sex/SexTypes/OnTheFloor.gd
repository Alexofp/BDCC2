extends SexTypeBase

const ROLE_DOM = "dom"
const ROLE_SUB = "sub"

func _init() -> void:
	id = SexType.OnTheFloor
	poseSupport = true

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_DOM, ROLE_SUB])
	pickRandomPose()
	
func onStart():
	pass

func start_run():
	#playAnim(AnimScene.SexStart, "start", {dom=ROLE_DOM, sub=ROLE_SUB})
	playAnim(AnimScene.SexStart, "start", {dom=ROLE_DOM, sub=ROLE_SUB})

func start_actions(_role:String):
	if(!hasMainActivity()):
		if(canDoDomActions(_role)):
			addAction(action("Stop").delayCancel(0.5).do("stopSex").setScore(scoreSexStop(_role)))

func start_do(_role:String, _id:String, _args:Array):
	if(_id == "stopSex"):
		getSexEngine().stopSex()
