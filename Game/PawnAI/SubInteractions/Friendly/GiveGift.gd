extends InteractionSocialBase

var itemUniqueID:int = -1
var giftOutcome:int = 0 # 0 = nope, 1 = meh, 2 = good, 3 = great
var savedGiftValue:float = 0.0

func saveData() -> Dictionary:
	var _data:Dictionary = super.saveData()
	_data["itemUniqueID"] = itemUniqueID
	_data["giftOutcome"] = giftOutcome
	_data["savedGiftValue"] = savedGiftValue
	return _data

func loadData(_data:Dictionary):
	super.loadData(_data)
	itemUniqueID = SAVE.loadInt(_data, "itemUniqueID", -1)
	giftOutcome = SAVE.loadInt(_data, "giftOutcome", 0)
	savedGiftValue = SAVE.loadFloat(_data, "savedGiftValue")

func _init() -> void:
	id = "GiveGift"
	socialActionName = "Give gift"
	socialActionCategory = CATEGORY_FRIENDLY
	socialIATags = {IATag.GiveGift: 1.0}
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_FRIENDLY - 11.0

func prepareChanceCalculator():
	setChanceCalculator(SICCAlways.new())

func prepareUnlockConditions():
	#addUnlockCondition(SocialUnlockAffectionCondition.new(0.1))
	pass

func onSocialInteractionEnd():
	addSocialExhaustion(0.1)
	if(giftOutcome <= 0):
		addSocialCooldown()
	#elif(giftOutcome == 1):
	#	addSocialCooldown(100.0)
	
	#if(isCriticalSuccess()):
	#	addRewardAffection(1.0)
		#addMemoryTarget(FriendlyMemories.Compliment)
	if(isCriticalFail()):
		addRewardAffection(-0.5)
	#elif(isSuccess()):
	#	addRewardAffection(0.4)
		#addMemoryTarget(FriendlyMemories.Compliment)
	elif(isFail()):
		addRewardAffection(-0.1)

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	# If we have anything that we can gift
	return _c.main.hasItemsCanGift()

func start(_roles:Dictionary, _args:Array):
	startSocialInteraction()
	socialInteractionStart()
	pushSay(ROLE_MAIN, "GiveGiftBegin", ROLE_TARGET)

var cacheItemToValue:Dictionary[int, float]
func _actions(_role:int):
	if(_role == ROLE_MAIN):
		addAction(action("give_nothing", "Cancel the gift").setFallback(1.0).setOnTimeout(5.0))
		
		var theInv := getInventory(ROLE_MAIN)
		for theItem:ItemBase in theInv.items: # Cache these actions?
			if(!theItem.canGiftItemAtAll()):
				continue
			if(!cacheItemToValue.has(theItem.uniqueID)):
				cacheItemToValue[theItem.uniqueID] = calcGiftValueOf(theItem)
			addAction(action("gift", theItem.getName()+" (Value: "+str(int(Util.roundF(cacheItemToValue[theItem.uniqueID]*100.0)))+"%)", cacheItemToValue[theItem.uniqueID]).setArgs([theItem.uniqueID]))
			
	if(_role == ROLE_TARGET):
		addAction(action("base_cancel_annoyed", "Cancel talk").setOnTimeout(10.0).setShowAfter(5.0))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "gift"):
		itemUniqueID = _action.args[0]
		var theItem := getGiftedItem()
		
		var theValue:float = calcGiftValue()
		if(theValue >= 1.0):
			giftOutcome = 3
		elif(theValue >= 0.45 || (theValue>0.0 && RNG.chance(theValue*30.0))):
			giftOutcome = 2
		elif(theValue > 0.0 || (theValue>0.0 && RNG.chance(theValue*100.0))):
			giftOutcome = 1
		else:
			giftOutcome = 0
		savedGiftValue = theValue
		
		pushSayRaw(ROLE_MAIN, theItem.getName()+". Do you like it?")
		#pushSay(ROLE_MAIN, "GiveGiftGive", ROLE_TARGET, {itemName=theItem.getName()})
		pushEvent("showValue")
		pushDelay(1.0)
		pushSetState("answer")
	if(_action.id == "give_nothing"):
		markInteractionShouldEndTalking()
		addAnnoyanceTarget(0.2)
		pushSay(ROLE_MAIN, "GiveGiftNothing", ROLE_TARGET)
		pushStopInteraction()
	if(_action.id == "base_cancel_annoyed"):
		markInteractionShouldEndTalking()
		if(!isObeying(ROLE_TARGET, ROLE_MAIN)):
			say(ROLE_TARGET, "TalkStopWastingTime", ROLE_MAIN)
			addAnnoyanceTarget(0.2)
		pushStopInteraction()

func onQueueEvent(_eventID:String, _args:Array):
	if(_eventID == "showValue"):
		getPawn(ROLE_TARGET).addSmallText("Gift success: "+str(Util.roundF(savedGiftValue*100.0, 1))+"%")
	if(_eventID == "giftReward"):
		var relationshipChanges:Dictionary[int, float] = _args[0]
		var theMult:float = 1.0
		if(giftOutcome == 1):
			theMult = 0.3
		elif(giftOutcome == 3):
			theMult = 2.0
		if(savedGiftValue < 0.2):
			theMult = clampf(savedGiftValue, 0.0, 0.2)
		theMult *= getTraitValueMult(ROLE_TARGET, TraitValue.GiftReward)
		
		for _rsValue:int in relationshipChanges:
			var theVal:float = relationshipChanges[_rsValue]
			RSValue.addValuePawnsShowMessage(_rsValue, getPawn(ROLE_MAIN), getPawn(ROLE_TARGET), theMult*theVal)
		addSocialCooldownSpecific("GiveGiftCD", 600.0)
		
func answer_actions(_role:int):
	if(_role == ROLE_TARGET):
		var agreeScore := 1.0 if giftOutcome > 0 else 0.0#scoreSocialAgree() if !isPlayer(ROLE_TARGET) else 1.0
		addAction(action("base_yes", "Accept gift", agreeScore))
		addAction(action("base_no", "Deny", 1.0 - agreeScore))
	if(_role == ROLE_MAIN):
		addAction(action("base_cancel_main", "Cancel talk").setOnTimeout(10.0).setShowAfter(5.0))

func answer_do(_role:int, _action:InteractionAction):
	if(_action.id == "base_cancel_main"):
		markInteractionShouldEndTalking()
		if(!isObeying(ROLE_MAIN, ROLE_TARGET)):
			say(ROLE_MAIN, "TalkStopWastingTime", ROLE_TARGET)
			addAnnoyanceMain(0.2)
		pushStopInteraction()
	elif(_action.id == "base_yes"):
		socialInteraction.chances.z = 1.0 if giftOutcome >= 3 else 0.0
		socialInteractionAgree()
		socialInteraction.chances.z = 0.0
		
		var theItem := getGiftedItem()
		var theInvGiver := getInventory(ROLE_MAIN)
		var theInvReceiver := getInventory(ROLE_TARGET)
		if(theItem && theInvGiver && theInvReceiver):
			theInvGiver.removeItem(theItem)
			theInvReceiver.addItem(theItem)
		
		var theCooldownID:String = theItem.getGiftCooldownIDFinal()
		addActionCooldown(ROLE_TARGET, ROLE_MAIN, theCooldownID, theItem.getGiftCooldownAmount())
		
		if(isCritical()):
			pushDelay(1.0)
		
		var theDialogueLine:String = "GiveGiftAccept"
		if(giftOutcome == 1):
			theDialogueLine = "GiveGiftAcceptMeh"
		if(giftOutcome == 3):
			theDialogueLine = "GiveGiftAcceptCrit"
		pushSay(ROLE_TARGET, theDialogueLine, ROLE_MAIN)
		pushEvent("giftReward", [theItem.getGiftRelationshipChanges(ItemValueContext.make(getChar(ROLE_TARGET), getChar(ROLE_MAIN), ItemValueContext.Gift))])
		pushSocialEnd()
		pushStopInteraction()
	elif(_action.id == "base_no"):
		socialInteractionDeny()
		if(isCritical()):
			pushDelay(1.0)
		pushSay(ROLE_TARGET, "GiveGiftDeny" if !isCritical() else "GiveGiftDenyCrit", ROLE_MAIN)
		pushSocialEnd()
		pushStopInteraction()

func doesMainHaveItemStill() -> bool:
	if(itemUniqueID < 0):
		return true
	
	var theInv:Inventory = getInventory(ROLE_MAIN)
	if(!theInv):
		return false
	return theInv.findItemByUniqueIDOnlyStored(itemUniqueID) != null

func getGiftedItem() -> ItemBase:
	if(itemUniqueID < 0):
		return null
	var theInv:Inventory = getInventory(ROLE_MAIN)
	if(!theInv):
		return null
	return theInv.findItemByUniqueIDOnlyStored(itemUniqueID)

func calcGiftValue() -> float:
	return calcGiftValueOf(getGiftedItem())
	
func calcGiftValueOf(theItem:ItemBase) -> float:
	if(!theItem):
		return 0.0
	var theTargetInv:Inventory = getInventory(ROLE_TARGET)
	var amountHasAlready:int = theTargetInv.getAmountOfItemID(theItem.id)
	var theCooldownStacks:float = getActionCooldown(ROLE_TARGET, ROLE_MAIN, theItem.getGiftCooldownIDFinal()) / ItemBase.GIFT_COOLDOWN_TIME
	var theInteractionCooldownStacks:float = getActionCooldown(ROLE_TARGET, ROLE_MAIN, "GiveGiftCD") / 600.0
	
	var theCtx := ItemValueContext.make(getChar(ROLE_TARGET), getChar(ROLE_MAIN), ItemValueContext.Gift)
	var theValue:float = theItem.calculateItemValue(theCtx)
	
	if(amountHasAlready > 0):
		theValue *= pow(theItem.getGiftAlreadyHasThisItemValueDebuff(), float(amountHasAlready))
	if(theCooldownStacks > 0.0):
		theValue *= pow(theItem.getGiftCooldownEffect(), theCooldownStacks)
	if(theInteractionCooldownStacks > 0.0): # Each gift makes the next gift 20% less valuable
		theValue *= pow(0.8, theInteractionCooldownStacks)
	
	theValue *= getTraitValueMult(ROLE_TARGET, TraitValue.GiftValue)
	
	return theValue
