extends SexSideActivity

const ROLE_USER = "user"
const ROLE_TARGET = "target"

func _init():
	id = "Resist"

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info != _target):
		return
	if(!_sexEngine.isForced() || _info.canDoDomActions()):
		return
	var resistScore:float = _info.ai.getSmoothResistScore()
	addAction(action("Resist").setRoles({ROLE_USER:_info}).setScore(resistScore).setCooldown("subResist").start(id, {ROLE_USER:_info}))
	
func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_USER])
	pushResistMinigame()

func start_resistMinigame(_result:ResistMinigameResult):
	if(_result.didSubsWin()):
		doText(ROLE_USER, "{user.You} {user.youVerb manage} to lower the grip on {user.youHim}!")
		getSexEngine().addGrip(-0.4)
	addCooldown("subResist", 10.0)
	endActivity()
