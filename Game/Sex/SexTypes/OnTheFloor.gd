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
	addSexTypeActions(_role)

func start_do(_role:String, _id:String, _args:Array):
	if(handleStopSexAction(_role, _id, ROLE_DOM if _role == ROLE_SUB else ROLE_SUB)):
		return
	#if(_id == "stopSex"): # Handled by the handleStopSexAction()
	#	getSexEngine().stopSex()
