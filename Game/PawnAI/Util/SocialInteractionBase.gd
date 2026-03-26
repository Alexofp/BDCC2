extends RefCounted
class_name SocialInteractionBase

var id:String = ""

var state:String = ""

var interaction:InteractionBase
var main:CharacterPawn
var target:CharacterPawn

func canStart(_interaction:InteractionBase, _main:CharacterPawn, _target:CharacterPawn, _args:Array) -> bool:
	return false

func start(_args:Array):
	pass

func processRare():
	pass


func canStartFinal(_interaction:InteractionBase, _main:CharacterPawn, _target:CharacterPawn, _args:Array) -> bool:
	return canStart(_interaction, _main, _target, _args)
	
func setPawns(_main:CharacterPawn, _target:CharacterPawn):
	main = _main
	target = _target
	connectPawn(main)
	connectPawn(target)
	
func connectPawn(_pawn:CharacterPawn):
	if(!_pawn):
		return
	_pawn.tree_exiting.connect(clearPawn.bind(_pawn))

func clearPawn(_pawn:CharacterPawn):
	if(!_pawn):
		return
	if(main == _pawn):
		_pawn.tree_exiting.disconnect(clearPawn.bind(_pawn))
		main = null
	if(target == _pawn):
		_pawn.tree_exiting.disconnect(clearPawn.bind(_pawn))
		target = null

var wasDeleted:bool = false
