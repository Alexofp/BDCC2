extends ItemBase

var color:Color = Color("ff7070")
var pulledDown:bool = false

func _init():
	id = "PlainBra"

func getName() -> String:
	return "Plain bra"

func getSlot() -> int:
	return InventorySlot.UnderwearTop

func getOptions() -> Dictionary:
	return {
		"color": {
			name = "Color",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		"pulledDown": {
			name = "Pulled down",
			type = "bool",
			editors = [EDITOR_INTERACT],
		},
	}

func getActions() -> Array:
	var theActions:Array = []
	if(isEquipped()):
		if(pulledDown):
			theActions.append(itemAction("Pull up", "Pull the bra down!", "pullUp"))
		else:
			theActions.append(itemAction("Pull down", "Pull the bra up!", "pullDown"))
	return theActions

func tryDoActionSelf(_id:String, _args:Array):
	if(_id == "pullDown"):
		doDelayedDisplaceAction("DisplaceBra", 0.5, _id, _args, "{user.You} {user.youVerb displace} {user.yourHis} bra.")
		return
	if(_id == "pullUp"):
		doDelayedDisplaceAction("DisplaceBraUndo", 0.5, _id, _args, "{user.You} {user.youVerb restore} {user.yourHis} bra.")
		return
	
	doActionFinal(_id, _args)

func doAction(_id:String, _args:Array):
	if(_id == "pullUp"):
		setOptionValue("pulledDown", false)
	if(_id == "pullDown"):
		setOptionValue("pulledDown", true)

func getDisplaceActions(_context:Dictionary) -> Array[Dictionary]:
	var result:Array[Dictionary]= []
	if(!pulledDown):
		result.append({
			name = "Pull down",
			desc = "Pull the bra down.",
			action = "pullDown",
			args = [],
			score = 1.0,
			message = "{user.You} {user.youVerb pull} down {target.your} bra!",
			delay = 0.5,
		})
	return result

func resetEquippedState():
	if(pulledDown):
		setOptionValue("pulledDown", false)

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.CoversBreasts: !pulledDown,
	}

func getCoveredZones() -> Dictionary[int, bool]:
	return {
		#ZoneCover.Anything: true,
		ZoneCover.Breasts: !pulledDown,
		ZoneCover.Nipples: !pulledDown,
	}
