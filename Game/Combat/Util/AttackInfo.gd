extends RefCounted
class_name AttackInfo

var damage:float = 1.0 # More of a multiplier. Actual damage will depend on stats. 1.0 = just simple punch
var reach:float = 1.8 # meters
var spread:float = 30.0 # degrees
var knockback:float = 1.0 # Knockback on the non-blocking target
var knockbackBlocked:float = 2.0 # Knockback on the target that's blocking
var exhaustion:float = 0.05
var exhaustionHit:float = 0.05
var exhaustionBlocked:float = 0.15

static func create(_damage:float, _range:float, _spread:float) -> AttackInfo:
	var theInfo := AttackInfo.new()
	theInfo.damage = _damage
	theInfo.reach = _range
	theInfo.spread = _spread
	return theInfo

func setKnock(_knockback:float, _knockbackBlocked:float) -> AttackInfo:
	knockback = _knockback
	knockbackBlocked = _knockbackBlocked
	return self

func setExhaust(_hitOrMiss:float, _blockedMult:float = 3.0, _missMult:float = 1.0) -> AttackInfo:
	exhaustion = _hitOrMiss * _missMult
	exhaustionHit = _hitOrMiss
	exhaustionBlocked = _hitOrMiss * _blockedMult
	return self

func setExhaustHitBlock(_hitOrMiss:float, _blocked:float) -> AttackInfo:
	exhaustion = _hitOrMiss
	exhaustionHit = _hitOrMiss
	exhaustionBlocked = _blocked
	return self

func setExhaustFull(_missed:float, _hit:float, _blocked:float) -> AttackInfo:
	exhaustion = _missed
	exhaustionHit = _hit
	exhaustionBlocked = _blocked
	return self
