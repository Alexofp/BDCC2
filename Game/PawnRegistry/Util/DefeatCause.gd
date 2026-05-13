extends RefCounted
class_name DefeatCause

const TYPE_GENERIC := 0
const TYPE_ATTACK := 1

var type:int = TYPE_GENERIC
var attackContext:AttackContext
var causerPawn:CharacterPawn
var pawn:CharacterPawn

static func makeGeneric(_pawn:CharacterPawn) -> DefeatCause:
	var _cause:DefeatCause = DefeatCause.new()
	_cause.type = TYPE_GENERIC
	_cause.pawn = _pawn
	return _cause

static func makeFromAttack(_attackContext:AttackContext) -> DefeatCause:
	var _cause:DefeatCause = DefeatCause.new()
	_cause.type = TYPE_ATTACK
	_cause.pawn = _attackContext.target
	_cause.causerPawn = _attackContext.attacker
	_cause.attackContext = _attackContext
	return _cause

func isCausedByPawn(_pawn:CharacterPawn) -> bool:
	return causerPawn == _pawn
