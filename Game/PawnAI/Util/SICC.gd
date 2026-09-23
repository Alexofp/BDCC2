extends Object
class_name SICC

const Affection := 0
const Lust := 1
const PowerBalance := 2
const PowerBalanceSub := 3

static func getValuePawns(_type:int, _pawn1:CharacterPawn, _pawn2:CharacterPawn) -> float:
	if(_type == Affection):
		return GM.main.relationshipSystem.getAffection(_pawn1.getID(), _pawn2.getID())
	if(_type == Lust):
		return GM.main.relationshipSystem.getLust(_pawn1.getID(), _pawn2.getID())
	if(_type == PowerBalance):
		return GM.main.relationshipSystem.getPowerBalance(_pawn1.getID(), _pawn2.getID())
	if(_type == PowerBalanceSub):
		return -GM.main.relationshipSystem.getPowerBalance(_pawn1.getID(), _pawn2.getID())
	return 0.0
