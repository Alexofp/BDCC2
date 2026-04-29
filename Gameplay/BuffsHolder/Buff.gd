extends RefCounted
class_name Buff

# These should never be saved/loaded. If you're thinking about saving/loading these, think again

const COLOR_BUFF := Color.GREEN
const COLOR_DEBUFF := Color.RED
const COLOR_LUST := Color.PURPLE

var invisible:bool = false

func getName() -> String:
	return "CHANGE ME"

func getBuffText() -> String:
	return ""

func getColor() -> Color:
	return COLOR_BUFF

func apply(_holder:BuffsHolder):
	pass

# Util funcs
static func buffF(_f:float, _digitAm:int = 0) -> String:
	return ("+" if _f >= 0.0 else "")+str(Util.roundF(_f, _digitAm))
static func buffI(_i:int) -> String:
	return ("+" if _i >= 0 else "")+str(_i)

#func getBuffs() -> Array[Buff]:
#	return []

func setInvisible(_inv:bool) -> Buff:
	invisible = _inv
	return self
