extends SexSideActivity

const ROLE_MAIN = "main"
const ROLE_TARGET = "target"

func _init():
	id = "Bondage"

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info == _target):
		return
	if(_info.canDoDomActions()):
		addAction(action("GAG!").setCat(["Bondage"]).start({main=_info, target=_target}))
	

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_MAIN, ROLE_TARGET])
	
	addActionText("STARTED THE BONDAGE!")
	pushDelay(0.5)
	pushEvent(SexEvent.make("bondage"))

func start_event(_event:SexEvent):
	if(_event.id == "bondage"):
		var theChar := getRoleChar(ROLE_TARGET)
		theChar.getInventory().setEquippedItem(InventorySlot.Mouth, GlobalRegistry.createItem("BallGag"))
		
		addActionText("ENDED THE BONDAGE!")
		endActivity()
