extends Object
class_name Pronouns

enum {
	SameAsGender,
	
	HeHim,
	SheHer,
	TheyThem,
}

static func getAll() -> Array:
	return [SameAsGender, HeHim, SheHer, TheyThem]

static func getName(_pronouns:int) -> String:
	if(_pronouns == SameAsGender):
		return "Same as gender"
	if(_pronouns == HeHim):
		return "He/Him"
	if(_pronouns == SheHer):
		return "She/Her"
	if(_pronouns == TheyThem):
		return "They/Them"
	
	return "?error?"

static func getPronoun(_pronouns:int, _pronounType:int) -> String:
	if(_pronounType == PronounType.HeShe):
		return heShe(_pronouns)
	if(_pronounType == PronounType.HisHer):
		return hisHer(_pronouns)
	if(_pronounType == PronounType.HimHer):
		return himHer(_pronouns)
	if(_pronounType == PronounType.HasS):
		return hasS(_pronouns)
	if(_pronounType == PronounType.HimselfHerself):
		return himselfHerself(_pronouns)
	
	return "?error?"

static func heShe(_pronouns:int) -> String:
	if(_pronouns == HeHim):
		return "he"
	if(_pronouns == SheHer):
		return "she"
	if(_pronouns == TheyThem):
		return "they"
	
	return "?error?"

static func hisHer(_pronouns:int) -> String:
	if(_pronouns == HeHim):
		return "his"
	if(_pronouns == SheHer):
		return "her"
	if(_pronouns == TheyThem):
		return "their"
	
	return "?error?"

static func himHer(_pronouns:int) -> String:
	if(_pronouns == HeHim):
		return "him"
	if(_pronouns == SheHer):
		return "her"
	if(_pronouns == TheyThem):
		return "them"
	
	return "?error?"

# He writes (s required)
# They write (no s required)
static func hasS(_pronouns:int) -> String:
	if(_pronouns == HeHim):
		return "s"
	if(_pronouns == SheHer):
		return "s"
	if(_pronouns == TheyThem):
		return ""
	
	return "s"

static func himselfHerself(_pronouns:int) -> String:
	if(_pronouns == HeHim):
		return "himself"
	if(_pronouns == SheHer):
		return "herself"
	if(_pronouns == TheyThem):
		return "themselves"
	
	return "?error?"
