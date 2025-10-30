extends ItemBase

var color1:Color = Color("262626")
var color2:Color = Color("521e00")
var color3:Color = Color("ff6600")
var pulledUp:bool = false

func _init():
	id = "InmateTop"

func getName() -> String:
	return "Inmate top"

func getSlot() -> int:
	return InventorySlot.Top

func getOptions() -> Dictionary:
	return {
		"color1": {
			name = "Color 1",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		"color2": {
			name = "Color 2",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		"color3": {
			name = "Color 3",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		"pulledUp": {
			name = "Pulled up",
			type = "bool",
			editors = [EDITOR_INTERACT],
		},
	}

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.CoversBreasts: !pulledUp,
	}

func getActions() -> Array:
	var theActions:Array = []
	if(isEquipped()):
		if(pulledUp):
			theActions.append(itemAction("Pull down", "Pull the top down!", "pullDown"))
		else:
			theActions.append(itemAction("Pull up", "Pull the top up!", "pullUp"))
	return theActions

func doAction(_id:String, _args:Array):
	if(_id == "pullDown"):
		setOptionValue("pulledUp", false)
	if(_id == "pullUp"):
		setOptionValue("pulledUp", true)

func getDisplaceActions(_context:Dictionary) -> Array[Dictionary]:
	var result:Array[Dictionary]= []
	if(!pulledUp):
		result.append({
			name = "Pull up",
			desc = "Pull the top up.",
			action = "pullUp",
			args = [],
			score = 1.0,
			message = "{user.You} {user.youVerb pull} up {target.your} top!",
			delay = 0.5,
		})
	return result

#func getSexEngineActions(_sexEngine:SexEngine, _info:SexParticipantInfo, _target:SexParticipantInfo) -> Array[SexAction]:
#	SexAction

func resetEquippedState():
	if(pulledUp):
		setOptionValue("pulledUp", false)

func getCoveredZones() -> Dictionary[int, bool]:
	return {
		ZoneCover.Anything: true,
		ZoneCover.Breasts: !pulledUp,
		ZoneCover.Nipples: !pulledUp,
	}
