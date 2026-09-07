extends SexTypeBase

const ROLE_DOM = "dom"

func _init() -> void:
	id = SexType.Solo
	poseSupport = true

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_DOM])
	pickRandomPose()
	
func onStart():
	pass

func start_run():
	playAnim(AnimScene.SoloSex, "start", {dom=ROLE_DOM})

func start_actions(_role:String):
	addSexTypeActions(_role)
	
func start_do(_role:String, _id:String, _args:Array):
	if(handleStopSexAction(_role, _id, ROLE_DOM)):
		return
