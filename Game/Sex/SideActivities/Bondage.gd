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
		
		for theItem in theInv.getItems():
			if(!theItem.isEquipable() || !theItem.isBondageGear()):
				continue
			if(!theItem.canBeEquippedOnto(theTargetInv)):
				continue # Show a disabled button instead?
			addAction(action(theItem.getName()).
				setCat(["Bondage", theCharName]).
				expose(_info, _target, Fetish.Bondage).
				#consent().
				start({ROLE_MAIN:_info,ROLE_TARGET:_target}, {itemID=theItem.uniqueID})
			)
		
		#addAction(action("GAG!").setCat(["Bondage"]).start({main=_info, target=_target}))
	

func start(_roles:Dictionary, _args:Dictionary):
	setupRoles(_roles, [ROLE_MAIN, ROLE_TARGET])
	
	if(_args.is_empty()):
		endActivity()
		return
	
	addActionText("STARTED THE BONDAGE!")
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
		
		addActionText("ENDED THE BONDAGE!")
		endActivity()
