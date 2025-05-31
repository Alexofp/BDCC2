extends Object
class_name Gender

enum {
	Male,
	Female,
	Androgynous,
	NonBinary,
}

static func getAll() -> Array:
	return [Male, Female, Androgynous, NonBinary]

static func getName(theGender:int) -> String:
	if(theGender == Male):
		return "Male"
	if(theGender == Female):
		return "Female"
	if(theGender == Androgynous):
		return "Androgynous"
	if(theGender == NonBinary):
		return "Non-binary"
	
	return "Unknown?"

static func getDefaultPronouns(theGender:int) -> int:
	if(theGender == Male):
		return Pronouns.HeHim
	if(theGender == Female):
		return Pronouns.SheHer
	if(theGender == Androgynous):
		return Pronouns.TheyThem
	if(theGender == NonBinary):
		return Pronouns.TheyThem
	
	return Pronouns.TheyThem
