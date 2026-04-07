extends PawnActionBase

func _init() -> void:
	id = "TalkTest2"
	alwaysCheckBitfield = CHECK_OTHER | CHECK_OTHER_QUICKACTION
	subCategory = [C_TALK]

func getVisibleName(_context:PawnActionContext) -> String:
	return "DO TEST"

func canDoAction(_context:PawnActionContext) -> bool:
	if(!_context.isTargetAPawn()):
		return false
	if(_context.pawn.hasInteraction()):
		return false
	if(_context.target.hasInteraction()):
		return false
	#if(GM.sitManager.isSitting(_context.pawn)):
	#	return false
	#if(GM.sitManager.isSitting(_context.getTargetPawn())):
	#	return false
	return true

func doAction(_context:PawnActionContext) -> bool:
	#var thePawn:CharacterPawn = _context.target
	#thePawn.ai.goalHandler.addGoal("StartFriendlyFight", [_context.pawn])
	#thePawn.ai.goalHandler.addGoal("StartHug", [_context.pawn])
	#GM.main.coupleAnimsSystem.start("Hug", _context.pawn, thePawn)
	
	var propHandler := _context.pawn.getSitPropHandler()
	if(!propHandler && _context.pawn.isSittingSomewhere()):
		# Failed
		return true
	if(propHandler):
		var theSexStartInfo := propHandler.getSexStartInfo([_context.target, _context.pawn])
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
	#newSex.addRole("dom", _context.pawn.getCharID(), SexRole.Dom)
	#newSex.addRole("sub", _context.target.getCharID(), SexRole.Sub)
	newSex.addRole("dom", _context.target.getCharID(), SexRole.Dom)
	newSex.addRole("sub", _context.pawn.getCharID(), SexRole.Sub)
	newSex.pos = _context.pawn.global_position
	newSex.ang = _context.pawn.global_rotation
	GM.sexManager.startSex(newSex)
	
	return true
