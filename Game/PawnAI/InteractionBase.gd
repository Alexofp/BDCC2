extends RefCounted
class_name InteractionBase

const ROLE_MAIN = 0
const ROLE_TARGET = 1
const ROLE_EXTRA = 2
const ROLE_EXTRA2 = 3

var id:String = ""

var roleToID:Dictionary[int, String] = {}
var idToRole:Dictionary[String, int] = {}

var rareTimer:float = 1.0

func involve(_role:int, _pawn:CharacterPawn):
	if(!_pawn):
		assert(false, "PAWN IS NULL")
		return
	if(_pawn.hasInteraction()):
		assert(false, "PAWN ALREADY HAS AN INTERACTION "+str(_pawn.id))
		return
	roleToID[_role] = _pawn.id
	idToRole[_pawn.id] = _role
	_pawn.setInteraction(self)

func startFinal(_roles:Dictionary, _args:Array):
	rareTimer = RNG.randfRange(0.5, 1.0)
	start(_roles, _args)

func start(_roles:Dictionary, _args:Array):
	pass

func processInteraction(_dt:float):
	rareTimer -= _dt
	if(rareTimer <= 0.0):
		rareTimer = 1.0
		processRare()

func processRare():
	pass

func getPawn(_role:int) -> CharacterPawn:
	if(!roleToID.has(_role)):
		return null
	return GM.pawnRegistry.getPawn(roleToID[_role])

func getChar(_role:int) -> BaseCharacter:
	if(!roleToID.has(_role)):
		return null
	return GM.characterRegistry.getCharacter(roleToID[_role])

func getCharID(_role:int) -> String:
	if(!roleToID.has(_role)):
		return ""
	return roleToID[_role]
