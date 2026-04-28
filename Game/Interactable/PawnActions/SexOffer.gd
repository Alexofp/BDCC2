extends PawnActionBase

func _init() -> void:
	id = "SexOffer"
	alwaysCheckBitfield = CHECK_OTHER

func getVisibleName(_context:PawnActionContext) -> String:
	return "Offer sex"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.isTargetAPawn()):
		return false
	var theTarget:CharacterPawn = _context.target
	if(theTarget.isDoingACoupleAnimation() || theTarget.isDoingSex()):
		return false
	#if(_context.target.isDefeated()):
	#	return false
	#if(GM.sitManager.isSitting(_context.pawn)):
	#	return false
	
	# Checking if the prop that we're sitting on support sex
	var propHandler := _context.pawn.getSitPropHandler()
	if(!propHandler && _context.pawn.isSittingSomewhere()):
		return false
	if(propHandler):
		var theSexStartInfo := propHandler.getSexStartInfo([_context.pawn, _context.target])
		if(theSexStartInfo.is_empty()):
			return false
	
	if(GM.sitManager.isSitting(_context.getTargetPawn()) && !_context.getTargetPawn().isSittingOn(propHandler)):
		return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	#GM.sexManager.askStartMasturbation(_context.pawn.getCharID())
	
	startDelayedAction("{user.You} {user.youVerb ask} to have sex with {target.you}!", _context, 10.0, _context.args
	).setTimerType(ActionSystemEntry.TIMER_MUST_CONSENT)
	return true

func doDelayedAction(_context:PawnActionContext) -> bool:
	var propHandler := _context.pawn.getSitPropHandler()
	if(!propHandler && _context.pawn.isSittingSomewhere()):
		# Failed
		return true
	if(propHandler):
		var theSexStartInfo := propHandler.getSexStartInfo([_context.pawn, _context.target])
		if(theSexStartInfo.is_empty()):
			# Can't do it on this prop
			return true
		
		var addedDom:bool = false
		
		var propSex := SexStartConf.new()
		propSex.sexType = theSexStartInfo["sexType"]
		for roleID in theSexStartInfo["roles"]:
			var thePawn:CharacterPawn = theSexStartInfo["roles"][roleID]
			propSex.addRole(roleID, thePawn.getCharID(), SexRole.Dom if !addedDom else SexRole.Sub)
			addedDom = true
		#propSex.addRole("sub", _context.target.getCharID(), SexRole.Sub)
		propSex.pos = theSexStartInfo["pos"]
		propSex.ang = theSexStartInfo["ang"]
		GM.sexManager.startSex(propSex)
		return true
		
	var newSex := SexStartConf.new()
	newSex.sexType = SexType.OnTheFloor
	newSex.addRole("dom", _context.pawn.getCharID(), SexRole.Dom)
	newSex.addRole("sub", _context.target.getCharID(), SexRole.Sub)
	newSex.pos = _context.pawn.global_position
	newSex.ang = _context.pawn.global_rotation
	GM.sexManager.startSex(newSex)
	
	return true
