extends SexSideActivity

const ROLE_MAIN = "main"
const ROLE_TARGET = "target"

func _init():
	id = "Strapons"

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	#if(_info == _target):
	#	return
	if(_info.canDoDomActions()):
		var theChar := _info.getChar()
		var theInv:Inventory = theChar.getInventory()
		var theTargetChar := _target.getChar()
		var theTargetInv:Inventory = theTargetChar.getInventory()
		var theCharName:String = theTargetChar.getName()
		
		if(!theTargetChar.canWearStrapon()):
			return
		
		#var tieUpScore:float = _info.taskScore(SexTask.TieUp, [_target.getID()])
		var straponScore:float = _info.taskScore(SexTask.WearStrapon, [_target.getID()])
		
		var theStraponsToWear := theInv.getStraponsToEquipToOthers()
		
		if(_info.canWearFreeStrapon()):
			var freeStraponRef := GlobalRegistry.getItemRef("StraponHuman")
			if(freeStraponRef.canBeEquippedOnto(theTargetInv)):
				var theItemName:String = "Free basic strapon"#freeStraponRef.getName()
				addAction(action(theItemName)
					.setCat(["Wear", theCharName])
					.setScore(straponScore if theStraponsToWear.is_empty() else 0.0)
					#.expose(_info, _target, Fetish.Bondage)
					.consent([_target], conTexts("{dom.You} {dom.youVerb want} to put "+theItemName+" on {sub.you}.", "{dom.You} {dom.youVerb try|tries} to force "+theItemName+" on {sub.you}!", {dom=_info,sub=_target}))
					.delay(0.5)
					.start({ROLE_MAIN:_info,ROLE_TARGET:_target}, {freeStrapon="StraponHuman"})
				)
		
		for theItem in theStraponsToWear:
			if(!theItem.canBeEquippedOnto(theTargetInv)):
				continue
			var theItemName:String = theItem.getName()
			addAction(action(theItemName)
				.setCat(["Wear", theCharName])
				.setScore(straponScore)
				#.expose(_info, _target, Fetish.Bondage)
				.consent([_target], conTexts("{dom.You} {dom.youVerb want} to put "+theItemName+" on {sub.you}.", "{dom.You} {dom.youVerb try|tries} to force "+theItemName+" on {sub.you}!", {dom=_info,sub=_target}))
				.start({ROLE_MAIN:_info,ROLE_TARGET:_target}, {itemID=theItem.uniqueID})
			)

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_MAIN, ROLE_TARGET])
	
	var theSexEngine := getSexEngine()
	endActivity()
	if(_args.is_empty()):
		#endActivity()
		return
	
	if(_args.has("freeStrapon")):
		var freeStraponItemID:String = _args["freeStrapon"]
		var theActor := getRoleChar(ROLE_MAIN)
		var theActorInfo := getRoleInfo(ROLE_MAIN)
		var theTarget := getRoleChar(ROLE_TARGET)
		if(!theActor || !theTarget):
			return
		var theTargetInv:Inventory = theTarget.getInventory()
		var theItem := GlobalRegistry.createItem(freeStraponItemID)
		if(!theItem || !theItem.canBeEquippedOnto(theTargetInv)):
			return
		
		theActorInfo.setFreeStraponUniqueID(theItem.uniqueID)
		theTargetInv.equipItemFreeSlot(theItem)
		theSexEngine.markItemAsTemporary(theItem)
	
		var theItemName:String = theItem.getName()
		if(isForced()):
			doText(ROLE_MAIN, "{main.You} {main.youVerb manage} to force "+theItemName+" on {target.you}!")
		else:
			doText(ROLE_MAIN, "{main.You} {main.youVerb put} "+theItemName+" on {target.you}.")
		
		doHitAnimationRandom(ROLE_TARGET, 1.0)

	elif(_args.has("itemID")):
		var theItemUID:int = _args["itemID"]
		var theActor := getRoleChar(ROLE_MAIN)
		var theTarget := getRoleChar(ROLE_TARGET)
		if(!theActor || !theTarget):
			return
		
		var theActorInv:Inventory = theActor.getInventory()
		var theTargetInv:Inventory = theTarget.getInventory()
		
		var theItem := theActorInv.findItemByUniqueID(theItemUID)
		if(!theItem || !theItem.canBeEquippedOnto(theTargetInv)):
			return
		
		theActorInv.removeItem(theItem)
		if(!theTargetInv.equipItemFreeSlot(theItem)):
			theActorInv.addItem(theItem) # Cancel
		else:
			theSexEngine.markItemBelongsTo(theItem, theActor.getID())
		
		var theItemName:String = theItem.getName()
		if(isForced()):
			doText(ROLE_MAIN, "{main.You} {main.youVerb manage} to force "+theItemName+" on {target.you}!")
		else:
			doText(ROLE_MAIN, "{main.You} {main.youVerb wear} "+theItemName+" on {target.you}.")
		
		doHitAnimationRandom(ROLE_TARGET, 1.0)
