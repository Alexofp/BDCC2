extends Object
class_name RSValue

const Affection := 0
const Lust := 1
const PowerBalance := 2
const PowerBalanceSub := 3

const VALUE_TO_NAME_MAIN:Dictionary[int, String] = {
	Affection: "Affection",
	Lust: "Lust",
	PowerBalance: "Power balance",
}

const VALUE_TO_NAME_ALL:Dictionary[int, String] = {
	Affection: "Affection",
	Lust: "Lust",
	PowerBalance: "Power balance",
	PowerBalanceSub: "Power balance (sub)",
}

static func getMainWithNames() -> Dictionary[int, String]:
	return VALUE_TO_NAME_MAIN
static func getAllWithNames() -> Dictionary[int, String]:
	return VALUE_TO_NAME_ALL

const AFFECTION_MAX:float = 3.0
const AFFECTION_MIN:float = -3.0
const LUST_MAX:float = 3.0
const LUST_MIN:float = 0.0
const POWERBALANCE_LIMIT:float = 3.0

static func getValuePawns(_type:int, _pawn1:CharacterPawn, _pawn2:CharacterPawn) -> float:
	if(_type == Affection):
		return GM.main.relationshipSystem.getAffection(_pawn1.getID(), _pawn2.getID())
	if(_type == Lust):
		return GM.main.relationshipSystem.getLust(_pawn1.getID(), _pawn2.getID())
	if(_type == PowerBalance):
		return GM.main.relationshipSystem.getPowerBalance(_pawn1.getID(), _pawn2.getID())
	if(_type == PowerBalanceSub):
		return -GM.main.relationshipSystem.getPowerBalance(_pawn1.getID(), _pawn2.getID())
	Log.Printerr("getValuePawns() UNKNOWN TYPE: "+str(_type))
	return 0.0

static func setValuePawns(_type:int, _pawn1:CharacterPawn, _pawn2:CharacterPawn, _val:float):
	if(_type == Affection):
		GM.main.relationshipSystem.setAffection(_pawn1.getID(), _pawn2.getID(), _val)
	elif(_type == Lust):
		GM.main.relationshipSystem.setLust(_pawn1.getID(), _pawn2.getID(), _val)
	elif(_type == PowerBalance):
		GM.main.relationshipSystem.setPowerBalance(_pawn1.getID(), _pawn2.getID(), _val)
	elif(_type == PowerBalanceSub):
		GM.main.relationshipSystem.setPowerBalance(_pawn1.getID(), _pawn2.getID(), -_val)
	else:
		Log.Printerr("setValuePawns() UNKNOWN TYPE: "+str(_type))

static func addValuePawns(_type:int, _pawn1:CharacterPawn, _pawn2:CharacterPawn, _val:float, _showMessage:bool = false):
	if(_type == Affection):
		if(_showMessage):
			_pawn1.addAffection(_pawn2, _val)
		else:
			GM.main.relationshipSystem.addAffection(_pawn1.getID(), _pawn2.getID(), _val)
	elif(_type == Lust):
		if(_showMessage):
			_pawn1.addLust(_pawn2, _val)
		else:
			GM.main.relationshipSystem.addLust(_pawn1.getID(), _pawn2.getID(), _val)
	elif(_type == PowerBalance):
		if(_showMessage):
			_pawn1.addPowerBalance(_pawn2, _val)
		else:
			GM.main.relationshipSystem.addPowerBalance(_pawn1.getID(), _pawn2.getID(), _val)
	elif(_type == PowerBalanceSub):
		if(_showMessage):
			_pawn2.addPowerBalance(_pawn1, _val)
		else:
			GM.main.relationshipSystem.addPowerBalance(_pawn1.getID(), _pawn2.getID(), -_val)
	else:
		Log.Printerr("addValuePawns() UNKNOWN TYPE: "+str(_type))

static func addValuePawnsShowMessage(_type:int, _pawn1:CharacterPawn, _pawn2:CharacterPawn, _val:float):
	addValuePawns(_type, _pawn1, _pawn2, _val, true)
