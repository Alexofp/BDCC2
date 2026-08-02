extends RefCounted
class_name RandomizeSettingsHolder

var species:String = ""
var gender:int = CharacterGenerator.GENDER_RANDOM
var penis:int = CharacterGenerator.RANDOM_GENDER_BASED
var vagina:int = CharacterGenerator.RANDOM_GENDER_BASED
var breasts:int = CharacterGenerator.RANDOM_GENDER_BASED
var paletteType:int = -1

func getSettings() -> Dictionary[String, Dictionary]:
	var theSpeciesList:Array[Array] = [["", "Random"], [" ", "Random hybrid"]]
	for theSpeciesID in GlobalRegistry.getSpeciesAll():
		var theSpecies:SpeciesBase = GlobalRegistry.getSpecies(theSpeciesID)
		theSpeciesList.append([theSpeciesID, theSpecies.getName()])
	
	return {
		"species": {
			name = "Species",
			values = theSpeciesList,
			value = species,
		},
		"gender": {
			name = "Gender",
			values = [
				[CharacterGenerator.GENDER_RANDOM, "Random"],
				[Gender.Male, "Male"],
				[Gender.Female, "Female"],
				[Gender.Androgynous, "Androgynous"],
				[Gender.NonBinary, "NonBinary"],
			],
			value = gender,
		},
		"paletteType": {
			name = "Color palette",
			values = [
				[-1, "Random"],
			]+GenColorPaletteType.getAllWithNames(),
			value = paletteType,
		},
	}

func getSettingValue(_id:String) -> Variant:
	return get(_id)

func applySetting(_id:String, _value):
	set(_id, _value)

func apply(_gen:CharacterGenerator):
	if(species.is_empty()):
		_gen.species = []
	elif(species == " "):
		_gen.species = CharacterGenerator.generateSpecies(100.0)
	else:
		_gen.species = [species]
		
	_gen.paletteType = paletteType
	_gen.gender = gender

func saveData() -> Dictionary:
	return {
		species = species,
		gender = gender,
		penis = penis,
		vagina = vagina,
		breasts = breasts,
		paletteType = paletteType,
	}

func loadData(_data:Dictionary):
	species = SAVE.loadVar(_data, "species", "")
	gender = SAVE.loadVar(_data, "gender", CharacterGenerator.GENDER_RANDOM)
	penis = SAVE.loadVar(_data, "penis", CharacterGenerator.RANDOM_GENDER_BASED)
	vagina = SAVE.loadVar(_data, "vagina", CharacterGenerator.RANDOM_GENDER_BASED)
	breasts = SAVE.loadVar(_data, "breasts", CharacterGenerator.RANDOM_GENDER_BASED)
	paletteType = SAVE.loadVar(_data, "paletteType", -1)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.StrShort, species,
		Bins.I8, gender,
		Bins.I8, penis,
		Bins.I8, vagina,
		Bins.I8, breasts,
		Bins.I8, paletteType,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	species = _data.readStrShort()
	gender = _data.readI8()
	penis = _data.readI8()
	vagina = _data.readI8()
	breasts = _data.readI8()
	paletteType = _data.readI8()
	_data.endLoad()
