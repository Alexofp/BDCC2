extends RefCounted
class_name InteractionSystem

var interactions:Array[InteractionBase]
#var pawnToInteraction:Dictionary[CharacterPawn, InteractionBase]

func getInteractionOf(_pawn:CharacterPawn) -> InteractionBase:
	if(!_pawn):
		return null
	return _pawn.getInteraction()
	#if(!pawnToInteraction.has(_pawn)):
		#return null
	#return pawnToInteraction[_pawn]

func startInteraction(_interactionID:String, _roles:Dictionary[String, CharacterPawn], _args:Array = []) -> InteractionBase:
	var theInteraction:InteractionBase = GlobalRegistry.createInteraction(_interactionID)
	if(!theInteraction):
		return null
	interactions.append(theInteraction)
	if(!theInteraction.startFinal(_roles, _args)):
		interactions.erase(theInteraction)
		return null
	return theInteraction

func processInteractions(_dt:float):
	for interaction in interactions:
		interaction.processInteraction(_dt)

func removeInteraction(_interaction:InteractionBase):
	if(!_interaction || _interaction.wasDeleted):
		return
	_interaction.stopSubInteraction()
	_interaction.onEnd()
	for thePawn in _interaction.pawnToRole:
		#var thePawn:CharacterPawn = GM.pawnRegistry.getPawn(theCharID)
		if(thePawn && thePawn.getInteraction() == _interaction):
			#pawnToInteraction.erase(thePawn)
			thePawn.setInteraction(null)
			
	_interaction.wasDeleted = true
	interactions.erase(_interaction)

func getActionsFor(_pawn:CharacterPawn) -> Array[InteractAction]:
	var result:Array[InteractAction] = []
	
	for interaction in interactions:
		var theActions:Array = interaction.getActionsFor(_pawn)
		
		for actionEntry in theActions:
			var newInteractAction:InteractAction = InteractAction.new()
			newInteractAction.id = "act"
			newInteractAction.name = actionEntry["name"] if actionEntry.has("name") else "Unnammed action"
			newInteractAction.customInteractNode = self
			newInteractAction.args = [
				interaction, actionEntry,
			]
			
			result.append(newInteractAction)
	
	var ourPawn:CharacterPawn = _pawn
	if(ourPawn):
		var pawnPos:Vector3 = ourPawn.global_position
		
		var otherPawns:= GM.pawnRegistry.getPawnsNear(pawnPos, 3.0)
		for otherPawn in otherPawns:
			if(otherPawn == ourPawn):
				continue
			var theInteraction:= otherPawn.getInteraction()
			if(!theInteraction):
				continue
			var theInterruptActions := theInteraction.getInterruptActionsFor(otherPawn, _pawn)
			for actionEntry in theInterruptActions:
				var newInteractAction:InteractAction = InteractAction.new()
				newInteractAction.id = "int"
				newInteractAction.name = actionEntry["name"] if actionEntry.has("name") else "Unnammed action"
				newInteractAction.customInteractNode = self
				newInteractAction.customTargetNode = otherPawn
				newInteractAction.args = [
					theInteraction, actionEntry, otherPawn.getCharID(),
				]
				
				result.append(newInteractAction)
			
	return result

func doInteractorAction(_user, _action:InteractAction):
	if(_action.id == "act"):
		var theInteraction:InteractionBase = _action.args[0]
		if(!theInteraction || theInteraction.wasDeleted):
			return
		theInteraction.doActionFor(_user.getPawn().getCharID(), _action.args[1])
	elif(_action.id == "int"):
		var theInteraction:InteractionBase = _action.args[0]
		if(!theInteraction || theInteraction.wasDeleted):
			return
		theInteraction.doInterruptActionFor(_action.args[2], _user.getPawn().getCharID(), _action.args[1])

func stopAllInteractionsWith(_pawn:CharacterPawn):
	var interactionAmount:int = interactions.size()
	for _i in range(interactionAmount):
		var theInteraction:InteractionBase = interactions[interactionAmount-_i-1]
		
		if(theInteraction.isPawnInvolved(_pawn)):
			removeInteraction(theInteraction)
