extends RefCounted
class_name GenderPronounsProfile

var gender:int = Gender.Male
var pronouns:int = Pronouns.SameAsGender

var customGenderName:String = ""
var customPronouns:Dictionary = {}

func getGender() -> int:
	return gender

func getGenderName() -> String:
	if(customGenderName != ""):
		return customGenderName
	return Gender.getName(getGender())

func setGender(theGender:int, theCustomGenderName:String = ""):
	gender = theGender
	customGenderName = theCustomGenderName

func getPronouns() -> int:
	if(pronouns == Pronouns.SameAsGender):
		return Gender.getDefaultPronouns(gender)
	return pronouns

func getPronounsName() -> String:
	return getPronoun(PronounType.HeShe)+"/"+getPronoun(PronounType.HimHer)

func getPronoun(_pronounType:int) -> String:
	if(customPronouns.has(_pronounType)):
		return customPronouns[_pronounType]
	return Pronouns.getPronoun(getPronouns(), _pronounType)

func clearCustomPronouns():
	customPronouns.clear()

func addCustonPronoun(_pronounType:int, _newPronoun:String):
	if(!(_pronounType in PronounType.getAll())):
		return
	if(_newPronoun == ""):
		if(customPronouns.has(_pronounType)):
			customPronouns.erase(_pronounType)
		return
	customPronouns[_pronounType] = _newPronoun

func removeCustomPronoun(_pronounType:int):
	if(customPronouns.has(_pronounType)):
		customPronouns.erase(_pronounType)

func heShe() -> String:
	return getPronoun(PronounType.HeShe)

func hisHer() -> String:
	return getPronoun(PronounType.HisHer)

func himHer() -> String:
	return getPronoun(PronounType.HimHer)

func hasS() -> bool:
	return getPronoun(PronounType.HasS) != ""

func himselfHerself() -> String:
	return getPronoun(PronounType.HimselfHerself)

func saveData() -> Dictionary:
	return {
		gender = gender,
		pronouns = pronouns,
		customGenderName = customGenderName,
		customPronouns = customPronouns,
	}

func loadData(_data:Dictionary):
	gender = SAVE.loadVar(_data, "gender", Gender.Male)
	if(!(gender in Gender.getAll())):
		gender = Gender.Male
	pronouns = SAVE.loadVar(_data, "pronouns", Pronouns.SameAsGender)
	if(!(pronouns in Pronouns.getAll())):
		pronouns = Pronouns.SameAsGender
	customGenderName = SAVE.loadVar(_data, "customGenderName", "")
	customPronouns = SAVE.loadVar(_data, "customPronouns", {})
	for pronounType in customPronouns.keys():
		if(!(pronounType in PronounType.getAll())):
			customPronouns.erase(pronounType)
