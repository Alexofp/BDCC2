extends SexSideActivity

func _init():
	id = "Undress"

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info != _target):
		return
	addAction(action("UNDRESS!").delay(0.3).start({main=_info}))

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, ["main"])
	
	addActionText("STARTED THE UNDRESS!")
	pushDelay(0.5)
	pushEvent(SexEvent.make("DoUndress"))

func start_event(_event:SexEvent):
	addActionText("ENDED THE UNDRESS!")
	endActivity()
