extends RefCounted
class_name CharacterGenerator

const RANDOM_GENDER_BASED := -2
const RANDOM := -1
const NO := 0
const YES := 1

const GENDER_RANDOM:int = -1

var species:Array[String] = []
var gender:int = GENDER_RANDOM #GENDER_RANDOM or Gender.Male/etc
var penis:int = RANDOM_GENDER_BASED
var vagina:int = RANDOM_GENDER_BASED
var breasts:int = RANDOM_GENDER_BASED
var speciesTraits:Dictionary[String, float] = {} # trait = float

var parts:Dictionary[int, String] = {} # slot = part id

var character:BaseCharacter

var paletteType:int = -1
var colors:CharGenColorPalette

const HYBRID_GENERATION_CHANCE := 10.0

static func generateSpecies(_hybridChance:float = 0.0) -> Array[String]:
	#GEN: Add hybrid support here
	if(RNG.chance(_hybridChance)):
		var theSpeciesIDs:Array = GlobalRegistry.species.keys() #GEN: This could be improved with a smarter function
		theSpeciesIDs.shuffle()
		
		if(theSpeciesIDs.size() >= 2):
			return [
				theSpeciesIDs[0], theSpeciesIDs[1],
			]
	
	return [
		RNG.pick(GlobalRegistry.getSpeciesAll().keys()),
	]

func pickSpeciesTraits():
	speciesTraits.clear()
	
	var theFinalTraits:Dictionary[String, float] = {}
	for speciesID in species:
		var theSpecies:SpeciesBase = GlobalRegistry.getSpecies(speciesID)
		if(!theSpecies):
			continue
		var theSpeciesTraits := theSpecies.traits
		
		for theTraitID in theSpeciesTraits:
			theFinalTraits[theTraitID] = maxf(theSpeciesTraits[theTraitID], theFinalTraits[theTraitID]) if theFinalTraits.has(theTraitID) else theSpeciesTraits[theTraitID]
	
	for theTraitID in theFinalTraits:
		var theWeight:float = theFinalTraits[theTraitID]
		
		if(!RNG.chance(theWeight*100.0)):
			continue
		speciesTraits[theTraitID] = theWeight

func hasSpeciesTrait(_traitID:String) -> bool:
	return speciesTraits.has(_traitID)

func hasTrait(_traitID:String) -> bool: # Same as hasSpeciesTrait, easier to type
	return speciesTraits.has(_traitID)

static func generateGender() -> int:
	return RNG.pick([
		Gender.Male, Gender.Female,
	])

func pickPenisStatus():
	var _val:int = NO
	var _checkVal:int = penis
	
	if(_checkVal == RANDOM):
		_val = RNG.pick([NO, YES])
	elif(_checkVal == RANDOM_GENDER_BASED):
		if(gender == Gender.Male):
			_val = YES
		elif(gender == Gender.Female):
			_val = NO
		else:
			_val = RNG.pick([NO, YES])
	elif(_checkVal < NO):
		_val = NO
	
	penis = _val

func pickVaginaStatus():
	var _val:int = NO
	var _checkVal:int = vagina
	
	if(_checkVal == RANDOM):
		_val = RNG.pick([NO, YES])
	elif(_checkVal == RANDOM_GENDER_BASED):
		if(gender == Gender.Male):
			_val = NO
		elif(gender == Gender.Female):
			_val = YES
		else:
			_val = RNG.pick([NO, YES])
	elif(_checkVal < NO):
		_val = NO
	
	vagina = _val

func pickBreastsStatus():
	var _val:int = NO
	var _checkVal:int = breasts
	
	if(_checkVal == RANDOM):
		_val = RNG.pick([NO, YES])
	elif(_checkVal == RANDOM_GENDER_BASED):
		if(gender == Gender.Male):
			_val = NO
		elif(gender == Gender.Female):
			_val = YES
		else:
			_val = RNG.pick([NO, YES])
	elif(_checkVal < NO):
		_val = NO
	
	breasts = _val

func generateBasicStuff():
	if(species.is_empty()):
		species = generateSpecies(HYBRID_GENERATION_CHANCE)
	if(gender == GENDER_RANDOM):
		gender = generateGender()
	pickPenisStatus()
	pickVaginaStatus()
	pickBreastsStatus()
	
	pickSpeciesTraits()
	
	if(paletteType < 0):
		paletteType = GenColorPaletteType.getRandom()
	
	if(!colors):
		colors = CharGenColorPalette.new()
		colors.generate(paletteType)
	
	internal_pickBodyparts()

func generate(_char:BaseCharacter):
	character = _char
	
	generateBasicStuff()
	applyStuff()

func generateNew() -> BaseCharacter:
	var theChar := BaseCharacter.new()
	generate(theChar)
	return theChar

func applyStuff():
	character.species.setFromArray(species)
	character.gender.setGender(gender)
	character.thickness = randf_range(0.0, 2.0)
	character.smoothBody = randf_range(0.0, 1.0)
	character.chubbyness = clampf(randf_range(-2.0, 1.0), 0.0, 1.0)
	character.buttSize = clampf(randf_range(-1.0, 1.0), 0.0, 1.0)
	character.muscles = clampf(randf_range(-0.5, 1.0), 0.0, 1.0)
	
	internal_createBodyparts()
	
	var theSkinData := SkinTypeData.new()
	theSkinData.color = colors.skin
	character.setBaseSkinTypeData(SkinType.HumanSkin, theSkinData)
	var theFurData := SkinTypeData.new()
	theFurData.color = colors.fur.color1
	character.setBaseSkinTypeData(SkinType.Fur, theFurData)
	character.checkSkinTypesList()

func internal_createBodyparts():
	character.clearBodyparts()
	
	for theBodypartSlot in parts:
		var thePartID:String = parts[theBodypartSlot]
		var theBodypart := GlobalRegistry.createBodypart(thePartID)
		if(!theBodypart):
			continue
		theBodypart.generateFor(self) # Should this happen after addBodypart()?
		character.addBodypart(theBodypartSlot, theBodypart)

	for theBodypartSlot:int in BodypartSlot.getAll():
		var theLeftSlot := BodypartSlot.getLeftSlot(theBodypartSlot)
		if(theBodypartSlot == theLeftSlot || !parts.has(theLeftSlot)):
			continue
		var theExistingPart:BodypartBase = character.getBodypart(theLeftSlot)
		var theData := theExistingPart.saveData().duplicate(true)
		
		var theRightPart := GlobalRegistry.createBodypart(theExistingPart.id)
		theRightPart.loadData(theData)
		character.addBodypart(theBodypartSlot, theRightPart)

func internal_pickBodyparts():
	parts.clear()
	
	#GEN: Pick bodyparts based on species and penis/vag flags
	for theBodypartSlot:int in BodypartSlot.getAll():
		var theLeftSlot := BodypartSlot.getLeftSlot(theBodypartSlot)
		if(theBodypartSlot != theLeftSlot):
			continue
		
		if(theBodypartSlot == BodypartSlot.Penis && penis != YES):
			continue
		
		var thePartID:String = pickBodypartID(species, theBodypartSlot, gender)
		if(thePartID.is_empty()):
			continue
		parts[theBodypartSlot] = thePartID
	
	# Duplicate left ears/horns to the right
	#for theBodypartSlot:int in BodypartSlot.getAll():
		#var theLeftSlot := BodypartSlot.getLeftSlot(theBodypartSlot)
		#if(theBodypartSlot != theLeftSlot && parts.has(theLeftSlot)):
			#parts[theBodypartSlot] = parts[theLeftSlot]
	
	if(!parts.has(BodypartSlot.Body)):
		Log.Printerr("Character creator had to use a fallback for the body. Species: "+str(species)+" Gender: "+str(gender))
		parts[BodypartSlot.Body] = "FeminineBody"
	if(!parts.has(BodypartSlot.Head)):
		Log.Printerr("Character creator had to use a fallback for the head. Species: "+str(species)+" Gender: "+str(gender))
		parts[BodypartSlot.Head] = "HumanFeminineHead"

static func getSpeciesPossiblePartIDsRaw(_species:String, _slot:int, _gender:int) -> Dictionary[String, float]:
	if(!GlobalRegistry.species.has(_species)):
		return {}
	var theSpecies:SpeciesBase = GlobalRegistry.getSpecies(_species)
	
	var theParts := theSpecies.getPossiblePartIDs(_slot, _gender)
	theParts.merge(GlobalRegistry.getBodypartIDsForAnySpecies(_slot, _gender), false)
	
	return theParts

const PRIORITY_LEVEL := 1000.0

static func getSpeciesPossiblePartIDsPriorityFiltered(_species:String, _slot:int, _gender:int) -> Dictionary[String, float]:
	var theRawParts := getSpeciesPossiblePartIDsRaw(_species, _slot, _gender)
	if(theRawParts.is_empty()):
		return theRawParts
	
	var theResult:Dictionary[String, float] = {}
	var currentPrio:int = 0
	for thePartID in theRawParts:
		var theWeight:float = theRawParts[thePartID]
		var theNewPrio:int = 0
		while(theWeight >= PRIORITY_LEVEL):
			theNewPrio += 1
			theWeight -= PRIORITY_LEVEL
		
		if(theNewPrio > currentPrio):
			currentPrio = theNewPrio
			theResult.clear()
		
		theResult[thePartID] = theWeight
		
	return theResult

static func getSpeciesPossiblePartIDsPriorityFilteredMultiSpecies(_speciesMany:Array[String], _slot:int, _gender:int) -> Dictionary[String, float]:
	var theResult:Dictionary[String, float] = {}
	
	var currentPrio:int = 0
	for _species:String in _speciesMany:
		var theRawParts := getSpeciesPossiblePartIDsRaw(_species, _slot, _gender)
		if(theRawParts.is_empty()):
			continue
		
		for thePartID in theRawParts:
			var theWeight:float = theRawParts[thePartID]
			var theNewPrio:int = 0
			while(theWeight >= PRIORITY_LEVEL):
				theNewPrio += 1
				theWeight -= PRIORITY_LEVEL
			
			if(theNewPrio > currentPrio):
				currentPrio = theNewPrio
				theResult.clear()
			
			if(theNewPrio >= currentPrio):
				theResult[thePartID] = theWeight
		
	return theResult

static func pickBodypartID(_speciesMany:Array[String], _slot:int, _gender:int) -> String:
	var allPossibleParts := getSpeciesPossiblePartIDsPriorityFilteredMultiSpecies(_speciesMany, _slot, _gender)
	if(allPossibleParts.is_empty()):
		return ""
	var theTotalScore:float = 0.0
	for thePartID in allPossibleParts:
		theTotalScore += maxf(0.0, allPossibleParts[thePartID])
	
	if(theTotalScore < 1.0 && !RNG.chance(theTotalScore*100.0)):
		return ""
	return RNG.pickWeightedDict(allPossibleParts)
