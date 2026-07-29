extends RefCounted
class_name SpeciesBase

var id:String = "error"
var allowedParts:Dictionary[int, Dictionary] # parts[slot (int)][gender (int)][partID (string)] = weight (float)
var traits:Dictionary[String, float] # trait id = weight

func getName() -> String:
	return "Change me"

func getCharacterCreatorPartsTemplate(_gender:int) -> Dictionary:
	return {}

const ANY_GENDER := -1
const FALLBACK := -2

func registerStuff():
	registerTraits()
	registerAllowedParts()

func registerTraits():
	#addTrait(SpeciesTrait.LegsPlanti, 1.0)
	pass

func registerDefaultBodies():
	addPart(Gender.Female, "FeminineBody", 1.0)
	addPart(Gender.Male, "MasculineBody", 1.0)
	addPart(FALLBACK, "FeminineBody", 1.0)
	
	addPart(FALLBACK, "CaninePenis", 1.0)

func registerAllowedParts():
	registerDefaultBodies()
	
	#addPart(BodypartSlot.Head, FALLBACK, "HumanFeminineHead", 1.0)

func addTrait(_trait:String, _weight:float):
	traits[_trait] = _weight

func addPart(_gender:int, _partID:String, _weight:float):
	
	var thePart := GlobalRegistry.getBodypartRef(_partID)
	if(!thePart):
		return
	var _slot:int = thePart.getBodypartSlots()[0]
	_slot = BodypartSlot.getLeftSlot(_slot)
	
	#if(_slot == BodypartSlot.LeftEar):
	#	addPart(_gender, BodypartSlot.RightEar, _partID, _weight)
	#elif(_slot == BodypartSlot.LeftHorn):
	#	addPart(_gender, BodypartSlot.RightHorn, _partID, _weight)
	
	if(!allowedParts.has(_slot)):
		allowedParts[_slot] = {}
	var theSlotParts:Dictionary = allowedParts[_slot]
	if(!theSlotParts.has(_gender)):
		theSlotParts[_gender] = {}
	var theGenderParts:Dictionary = theSlotParts[_gender]
	#if(!theGenderParts.has(_partID)):
	#	theGenderParts[_partID] = {}
	#var thePartParts:Dictionary = theGenderParts[_partID]
	#thePartParts[_partID] = _weight
	theGenderParts[_partID] = _weight

func getPossiblePartIDs(_slot:int, _gender:int) -> Dictionary[String, float]:
	_slot = BodypartSlot.getLeftSlot(_slot)
	
	if(!allowedParts.has(_slot)):
		return {}
	var theSlotParts:Dictionary = allowedParts[_slot]
	
	var result:Dictionary[String, float] = {}
	
	if(theSlotParts.has(ANY_GENDER)):
		var theAnyGenderParts:Dictionary = theSlotParts[ANY_GENDER]
		for thePartID in theAnyGenderParts:
			var theWeight:float = theAnyGenderParts[thePartID]
			if(theWeight <= 0.0):
				continue
			result[thePartID] = theWeight
	
	if(theSlotParts.has(_gender)):
		var theGenderParts:Dictionary = theSlotParts[_gender]
		for thePartID in theGenderParts:
			var theWeight:float = theGenderParts[thePartID]
			if(theWeight <= 0.0):
				continue
			result[thePartID] = theWeight
	
	if(result.is_empty() && theSlotParts.has(FALLBACK)):
		var theFallbackParts:Dictionary = theSlotParts[FALLBACK]
		for thePartID in theFallbackParts:
			var theWeight:float = theFallbackParts[thePartID]
			if(theWeight <= 0.0):
				continue
			result[thePartID] = theWeight

	return result
