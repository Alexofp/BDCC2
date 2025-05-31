extends RefCounted
class_name SpeciesProfile

var mainSpecies:String = "Human"
var secondarySpecies:String = ""
var customName:String = ""

func getName() -> String:
	if(customName != ""):
		return customName
	if(mainSpecies == ""):
		return "Unknown"
	if(secondarySpecies == ""):
		var theSpeciesID:String = mainSpecies
		var theSpecies:SpeciesBase = GlobalRegistry.getSpecies(theSpeciesID)
		if(!theSpecies):
			return "Error:"+theSpeciesID
		return theSpecies.getName()
	
	var speciesNames:Array[String] = []
	for speciesID in [mainSpecies, secondarySpecies]:
		var theSpecies:SpeciesBase = GlobalRegistry.getSpecies(speciesID)
		if(!theSpecies):
			speciesNames.append(speciesID)
		else:
			speciesNames.append(theSpecies.getName())
	#speciesNames.sort()
	
	return Util.join(speciesNames, "-")+" hybrid"

func setMainSpecies(theSpeciesID:String):
	if(theSpeciesID == ""):
		Log.Printerr("Trying to set the main species to an empty species!")
		mainSpecies = "Human"
		return
	mainSpecies = theSpeciesID
	if(secondarySpecies == mainSpecies):
		secondarySpecies = ""

func setSecondarySpecies(theSpeciesID:String):
	if(theSpeciesID == mainSpecies):
		return
	secondarySpecies = theSpeciesID

func getMainSpeciesID() -> String:
	return mainSpecies
	
func getSecondarySpeciesID() -> String:
	return secondarySpecies

func isHybrid() -> bool:
	if(secondarySpecies != ""):
		return true
	return false

func saveData() -> Dictionary:
	return {
		mainSpecies = mainSpecies,
		secondarySpecies = secondarySpecies,
		customName = customName,
	}

func loadData(_data:Dictionary):
	mainSpecies = SAVE.loadVar(_data, "mainSpecies", "Human")
	secondarySpecies = SAVE.loadVar(_data, "secondarySpecies", "")
	customName = SAVE.loadVar(_data, "customName", "")
