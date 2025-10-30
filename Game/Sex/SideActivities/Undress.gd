extends SexSideActivity

const ROLE_USER = "user"
const ROLE_TARGET = "target"

func _init():
	id = "Undress"

func getStartActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo):
	#if(_info != _target):
	#	return
	#addAction(action("UNDRESS!").delay(0.3).start({main=_info}))
	var targetChar:BaseCharacter = _target.getChar()
	var targetInv:Inventory = targetChar.getInventory()
	var charCatName:String = targetChar.getName() if _info != _target else "You"
	
	var theContext := getContext()
	for invSlot in targetInv.getEquippedItems():
		var theItem := targetInv.getEquippedItem(invSlot)
		var itemCatName:String = theItem.getName()
		var finalCat:Array[String] = ["Inventory", charCatName, itemCatName]
		
		if(theItem.canUnequipInSex(theContext)):
			var takeOffScore:float = _info.taskScore(SexTask.Undress, [_target.getID()])
			addAction(action("Take off").setScore(takeOffScore).setCat(finalCat).start({ROLE_USER:_info,ROLE_TARGET:_target}, {action={delay=0.3,action="unequip",args=[]}, slot=invSlot}))
		
		var displaceActions := theItem.getDisplaceActions(theContext)
		for actionEntry in displaceActions:
			var actionName:String = actionEntry["name"]
			
			#var actionID:String = actionEntry["action"]
			var displaceScore:float = _info.taskScore(SexTask.Undress, [_target.getID()])
			addAction(action(actionName).setScore(displaceScore).setCat(finalCat).start({ROLE_USER:_info,ROLE_TARGET:_target}, {action=actionEntry, slot=invSlot}))
	
func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_USER, ROLE_TARGET])
	
	var invSlot:int = _args["slot"]
	var actionEntry:Dictionary = _args["action"]
	var actionDelay:float = actionEntry["delay"] if actionEntry.has("delay") else 0.0
	
	addActionText("STARTED THE UNDRESS!")
	pushDelay(actionDelay)
	pushEvent(SexEvent.make("DoUndress", [invSlot, actionEntry["action"], actionEntry["args"], actionEntry["message"] if actionEntry.has("message") else ""]))

func start_event(_event:SexEvent):
	var invSlot:int = _event.args[0]
	var actionID:String = _event.args[1]
	var actionArgs:Array = _event.args[2]
	var theUndressMessage:String = _event.args[3]
	
	var targetChar:BaseCharacter = getRoleChar(ROLE_TARGET)
	var targetInv:Inventory = targetChar.getInventory()
	var theItem:ItemBase = targetInv.getEquippedItem(invSlot)
	
	addActionText(theUndressMessage if !theUndressMessage.is_empty() else "{user.You} undressed {target.you}!")
	
	if(theItem):
		if(actionID == "unequip"):
			if(theItem.shouldAutoEquipAfterSex()):
				addAutoEquipAfterEnd(ROLE_TARGET, invSlot, theItem.uniqueID)
		theItem.doDisplaceAction(actionID, actionArgs, getContext())
	
	endActivity()
