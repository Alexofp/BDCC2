extends ItemBase

var color1:Color = Color("262626")
var color2:Color = Color("521e00")
var color3:Color = Color("ff6600")
var pulledDown:bool = false

func _init():
	id = "InmateShorts"

func getName() -> String:
	return "Inmate shorts"

func getSlot() -> int:
	return InventorySlot.Bottom

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
		"pulledDown": {
			name = "Pulled down",
			type = "bool",
			editors = [EDITOR_INTERACT],
		},
	}

func getSexHideTags() -> Dictionary:
	return {
		SexHideTag.CoversPenis: !pulledDown,
		SexHideTag.CoversVagina: !pulledDown,
		SexHideTag.CoversAnus: !pulledDown,
	}

func getActions() -> Array:
	var theActions:Array = []
	if(isEquipped()):
		if(!pulledDown):
			theActions.append(itemAction("Pull down", "Pull the shorts down!", "pullDown"))
		else:
			theActions.append(itemAction("Pull up", "Pull the shorts up!", "pullUp"))
	return theActions

func doAction(_id:String, _args:Array):
	if(_id == "pullDown"):
		setOptionValue("pulledDown", true)
	if(_id == "pullUp"):
		setOptionValue("pulledDown", false)

func getDisplaceActions(_context:Dictionary) -> Array[Dictionary]:
	var result:Array[Dictionary]= []
	if(!pulledDown):
		result.append({
			name = "Pull down",
			desc = "Pull the shorts down.",
			action = "pullDown",
			args = [],
			score = 1.0,
			message = "{user.You} {user.youVerb pull} down {target.your} shorts!",
			delay = 0.5,
		})
	return result

func resetEquippedState():
	if(pulledDown):
		setOptionValue("pulledDown", false)

func getCoveredZones() -> Dictionary[int, bool]:
	return {
		#ZoneCover.Anything: true,
		ZoneCover.Penis: !pulledDown,
		ZoneCover.Vagina: !pulledDown,
		ZoneCover.Anus: !pulledDown,
		ZoneCover.Thighs: pulledDown, # Shorts cover the thighs if pulled down
	}
