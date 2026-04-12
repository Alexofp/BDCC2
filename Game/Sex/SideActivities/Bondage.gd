extends SexSideActivity

const ROLE_MAIN = "main"
const ROLE_TARGET = "target"

func _init():
	id = "Bondage"

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	if(_info == _target):
		return
	if(_info.canDoDomActions()):
		var theChar := _info.getChar()
		var theInv:Inventory = theChar.getInventory()
		var theTargetChar := _target.getChar()
		var theTargetInv:Inventory = theTargetChar.getInventory()
		var theCharName:String = theTargetChar.getName()
		
		var tieUpScore:float = _info.taskScore(SexTask.TieUp, _target)
		
		for theItem in theInv.getBDSMGearToEquipToOthers():
			if(!theItem.canBeEquippedOnto(theTargetInv)):
				continue # Show a disabled button instead?
			var theItemName:String = theItem.getName()
			addAction(action(theItemName)
				.setRoles({ROLE_MAIN:_info,ROLE_TARGET:_target})
				.setCat(["Bondage", theCharName])
				.setScore(tieUpScore)
				.expose(ROLE_MAIN, ROLE_TARGET, Fetish.Bondage)
				.consent([ROLE_TARGET], conTexts("{dom.You} {dom.youVerb want} to put "+theItemName+" on {sub.you}.", "{dom.You} {dom.youVerb try|tries} to force "+theItemName+" on {sub.you}!", {dom=_info,sub=_target}))
				.start(id, {ROLE_MAIN:_info,ROLE_TARGET:_target}, {itemID=theItem.uniqueID})
			)
		

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_MAIN, ROLE_TARGET])
	
	if(_args.is_empty()):
		endActivity()
		return
	
	#addActionText("STARTED THE BONDAGE!")
	pushDelay(0.5)
	pushEvent(SexEvent.make("bondage", [_args["itemID"]]))

func start_event(_event:SexEvent):
	if(_event.id == "bondage"):
		var theItemUID:int = _event.args[0]
		var theActor := getRoleChar(ROLE_MAIN)
		var theTarget := getRoleChar(ROLE_TARGET)
		if(!theActor || !theTarget):
			endActivity()
			return
		
		var theActorInv:Inventory = theActor.getInventory()
		var theTargetInv:Inventory = theTarget.getInventory()
		
		var theItem := theActorInv.findItemByUniqueID(theItemUID)
		if(!theItem || !theItem.canBeEquippedOnto(theTargetInv)):
			endActivity()
			return
		
		theActorInv.removeItem(theItem)
		if(!theTargetInv.equipItemFreeSlot(theItem)):
			theActorInv.addItem(theItem) # Cancel
		
		var theItemName:String = theItem.getName()
		if(isForced()):
			doText(ROLE_MAIN, "{main.You} {main.youVerb manage} to force "+theItemName+" on {target.you}!")
		else:
			doText(ROLE_MAIN, "{main.You} {main.youVerb lock} "+theItemName+" on {target.you}.")
		
		doHitAnimationRandom(ROLE_TARGET, 1.0)
		completeTask(ROLE_MAIN, SexTask.TieUp, ROLE_TARGET)
		
		endActivity()
