extends InteractionSocialBase

var valueToEdit:int = -1

func _init() -> void:
	id = "DebugSocialInteraction"
	socialActionName = "Relationship values"
	socialActionCategory = CATEGORY_DEBUG
	
	registerForInteractionType = [InteractionType.Talking]
	interactionPriority = PRIO_DEBUG - 1.0

func prepareChanceCalculator():
	setChanceCalculator(SICCAlways.new())

func prepareUnlockConditions():
	pass

func canDoSocialAction(_c:SocialInteractionContext) -> bool:
	if(!OS.is_debug_build()):
		return false
	return true

func start(_roles:Dictionary, _args:Array):
	pass

func _actions(_role:int):
	if(_role == ROLE_MAIN):
		addAction(action("cancel", "Cancel").setFallback(1.0))
		addAction(action("addall", "+100% all").setArgs([1.0]))
		addAction(action("addall", "-100% all").setArgs([-1.0]))
		var theVals := RSValue.getAllWithNames()
		for theVal:int in theVals:
			var theName:String = theVals[theVal]
			addAction(action("pick", theName).setArgs([theVal]))
	#if(_role == ROLE_TARGET):
	#	addAction(action("base_cancel_annoyed", "Cancel talk").setOnTimeout(10.0).setShowAfter(5.0))

func _do(_role:int, _action:InteractionAction):
	if(_action.id == "cancel"):
		stopInteraction()
	if(_action.id == "pick"):
		if(_action.args.size() < 1):
			return
		valueToEdit = _action.args[0]
		setState("picked")
	if(_action.id == "addall"):
		if(_action.args.size() < 1):
			return
		for theVal:int in RSValue.getMainWithNames():
			RSValue.addValuePawnsShowMessage(theVal, getPawn(ROLE_MAIN), getPawn(ROLE_TARGET), _action.args[0])


func picked_actions(_role:int):
	if(_role == ROLE_TARGET):
		pass
	if(_role == ROLE_MAIN):
		addAction(action("cancel", "Enough").setFallback(1.0))
		addAction(action("add", "+300%").setArgs([3.0]))
		addAction(action("add", "-300%").setArgs([-3.0]))
		addAction(action("add", "+100%").setArgs([1.0]))
		addAction(action("add", "-100%").setArgs([-1.0]))
		addAction(action("add", "+50%").setArgs([0.5]))
		addAction(action("add", "-50%").setArgs([-0.5]))
		addAction(action("add", "+10%").setArgs([0.1]))
		addAction(action("add", "-10%").setArgs([-0.1]))

func picked_do(_role:int, _action:InteractionAction):
	if(_action.id == "cancel"):
		stopInteraction()
	if(_action.id == "add"):
		if(_action.args.size() < 1):
			return
		RSValue.addValuePawnsShowMessage(valueToEdit, getPawn(ROLE_MAIN), getPawn(ROLE_TARGET), _action.args[0])
