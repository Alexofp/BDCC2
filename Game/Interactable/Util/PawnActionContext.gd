extends RefCounted
class_name PawnActionContext

var pawn:CharacterPawn
var target

var args:Array

func getTargetPawn() -> CharacterPawn:
	if(target is CharacterPawn):
		return target
	return null

func isTargetAPawn() -> bool:
	if(target is CharacterPawn):
		return true
	return false

func clearContext():
	target = null
	args = []

func loadFromInteractEntryDo(_entry:InteractEntryDo, _target):
	target = _target#_entry.target
	args = _entry.args

func getArg(_indx:int, _default:Variant = null) -> Variant:
	if(_indx < 0 || _indx >= args.size()):
		return _default
	return args[_indx]
