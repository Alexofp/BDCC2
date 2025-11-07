extends ItemBase

var color:Color = Color.WHITE
#var shifted:bool = false

func _init():
	id = "StraponHuman"

func getName() -> String:
	return "Strapon (basic)"

func getSlot() -> int:
	return InventorySlot.UnderwearBottom

func getOptions() -> Dictionary:
	return {
		"color": {
			name = "Color",
			type = "color",
			editors = [EDITOR_INTERACT],
		},
		#"shifted": {
			#name = "Shifted to the side",
			#type = "bool",
			#editors = [EDITOR_INTERACT],
		#},
	}

#func getActions() -> Array:
	#var theActions:Array = []
	#if(isEquipped()):
		#if(!shifted):
			#theActions.append(itemAction("Shift aside", "Shift the panties aside!", "shiftAside"))
		#else:
			#theActions.append(itemAction("Shift back", "Shift the panties back!", "shiftBack"))
	#return theActions
#
#func doAction(_id:String, _args:Array):
	#if(_id == "shiftAside"):
		#setOptionValue("shifted", true)
	#if(_id == "shiftBack"):
		#setOptionValue("shifted", false)
#
#func getDisplaceActions(_context:Dictionary) -> Array[Dictionary]:
	#var result:Array[Dictionary]= []
	#if(!shifted):
		#result.append({
			#name = "Shift aside",
			#desc = "Shift the panties aside.",
			#action = "shiftAside",
			#args = [],
			#score = 1.0,
			#message = "{user.You} {user.youVerb shift} aside {target.your} panties!",
			#delay = 0.5,
		#})
	#return result
#
#func resetEquippedState():
	#if(shifted):
		#setOptionValue("shifted", false)

#func getSexHideTags() -> Dictionary:
	#return {
		#SexHideTag.CoversPenis: !shifted,
		#SexHideTag.CoversVagina: !shifted,
		#SexHideTag.CoversAnus: !shifted,
	#}
#
#func getCoveredZones() -> Dictionary[int, bool]:
	#return {
		##ZoneCover.Anything: true,
		#ZoneCover.Penis: !shifted,
		#ZoneCover.Vagina: !shifted,
		#ZoneCover.Anus: !shifted,
	#}
