extends SexSideActivity

const ROLE_USER = "user"
const ROLE_TARGET = "target"

func _init():
	id = "Talking"

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
	var theTags:int = _info.getTags(_target)
	
	if(theTags & SexTag.CanBegSex):
		addAction(action("Beg").setScore(0.05).setRoles({ROLE_USER:_info, ROLE_TARGET:_target}).setCooldown("talk", 10.0).start(id, {ROLE_USER:_info, ROLE_TARGET:_target}, {action="beg"}))
	if(_sexEngine.timeSinceAnyActions > 10.0 && !_sexEngine.hasMainActivity()):
		addAction(action("Tease").setScore(0.05 if !_sexEngine.isForced() else 0.0).setRoles({ROLE_USER:_info, ROLE_TARGET:_target}).setCooldown("talk", 10.0).start(id, {ROLE_USER:_info, ROLE_TARGET:_target}, {action="tease"}))
	
func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_USER, ROLE_TARGET])
	var theAction:String = _args.get("action", "")
	if(theAction == "beg"):
		startDialogue("BegSex", ROLE_USER, ROLE_TARGET)
	if(theAction == "tease"):
		startDialogue("Tease", ROLE_USER, ROLE_TARGET)
	endActivity()
