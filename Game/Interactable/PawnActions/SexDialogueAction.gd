extends PawnActionBase

const ARG_NAME = 0
const ARG_ACTION = 1 # say/ignore
const ARG_LINE = 2 # actual object. Either a line or a handler
const ARG_INDEX = 3 # an id of the finalLine

func _init() -> void:
	id = "SexDialogueAction"
	
	canDoBitfield = CAN_COLLAPSED | CAN_DEFEATED

func getVisibleName(_context:PawnActionContext) -> String:
	return _context.getArg(ARG_NAME, "ERROR?")

func canDoAction(_context:PawnActionContext) -> bool:
	return true

func doAction(_context:PawnActionContext) -> bool:
	var theSexEngine := GM.main.sex_manager.getSexEngineOfPawn(_context.pawn)
	if(theSexEngine):
		var theInfo := theSexEngine.getParticipant(_context.pawn.getID())
		# Do stuff here
		#theSexEngine.dialogue.
		if(_context.getArg(ARG_ACTION, "ERROR?") == "ignore"):
			var theHandler:SexDialogueHandler = _context.getArg(ARG_LINE, null)
			if(theHandler):
				theHandler.ignoreAllChainsThatNeedsAnsweringBy(theInfo)
			return true
		if(_context.getArg(ARG_ACTION, "ERROR?") == "say"):
			var theLine:SexDialogueLine = _context.getArg(ARG_LINE, null)
			if(theLine && theLine.chain && theLine.chain.handler):
				theLine.chain.handler.doAnswer(theLine, _context.getArg(ARG_INDEX, 0))
			return true
	return true
