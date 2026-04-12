extends SexSideActivity

const ROLE_USER = "user"
const ROLE_TARGET = "target"

func _init():
	id = "SayTest"

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info == _target):
		return
	#if(!_sexEngine.isForced() || _info.canDoDomActions()):
	#	return
	#var resistScore:float = _info.ai.getSmoothResistScore()
	#addAction(action("Resist").setScore(resistScore).setCooldown("subResist").start(id, {ROLE_USER:_info}))
	addAction(action("Say test").setRoles({ROLE_USER:_info, ROLE_TARGET:_target}).start(id, {ROLE_USER:_info, ROLE_TARGET:_target}))
	
func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_USER, ROLE_TARGET])
	startDialogue("WantMore", ROLE_USER, ROLE_TARGET)
	endActivity()
