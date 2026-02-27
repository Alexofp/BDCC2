extends RefCounted
class_name AttackInfo

var damage:float = 1.0 # More of a multiplier. Actual damage will depend on stats. 1.0 = just simple punch
var reach:float = 1.8 # meters
var spread:float = 30.0 # degrees
var knockback:float = 1.0 # Knockback on the non-blocking target
var knockbackBlocked:float = 2.0 # Knockback on the target that's blocking

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
