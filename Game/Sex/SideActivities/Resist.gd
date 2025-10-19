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
	addAction(action("Resist").setCooldown("subResist").start({ROLE_USER:_info}))
	
func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_USER])
	pushResistMinigame()

func start_resistMinigame(_result:ResistMinigameResult):
	if(_result.didSubsWin()):
		getSexEngine().addGrip(-0.4)
	addCooldown("subResist", 20.0)
	endActivity()
