extends SexSideActivity

const ROLE_USER = "user"
const ROLE_TARGET = "target"

func _init():
	id = "Begging"

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info == _target):
		return
	if(_info.canDoDomActions()):
		return
	if(!_sexEngine.dialogue.canDoDialogue()):
		return
	#if(!_sexEngine.isForced() || _info.canDoDomActions()):
	#	return
	#var resistScore:float = _info.ai.getSmoothResistScore()
	#addAction(action("Resist").setScore(resistScore).setCooldown("subResist").start(id, {ROLE_USER:_info}))
	if(_info.hasTag(_target, SexTag.CanBegSex)):
		addAction(action("Beg").setCooldown("beg", 10.0).setRoles({ROLE_USER:_info, ROLE_TARGET:_target}).start(id, {ROLE_USER:_info, ROLE_TARGET:_target}, {action="beg"}))
	
func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_USER, ROLE_TARGET])
	var theAction:String = _args.get("action", "")
	if(theAction == "beg"):
		startDialogue("BegSex", ROLE_USER, ROLE_TARGET)
	endActivity()
