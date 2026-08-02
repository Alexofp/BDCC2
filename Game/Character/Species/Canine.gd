extends SpeciesBase

func _init() -> void:
	id = "Canine"

func getName() -> String:
	return "Canine"

func registerTraits():
	addTrait(SpeciesTrait.LegsDigi, 1.0)
	addTrait(SpeciesTrait.HandsPaws, 1.0)
	addTrait(SpeciesTrait.CanineVagina, 0.3)

func registerAllowedParts():
	registerDefaultBodies()
	
	addPart(ANY_GENDER, "FluffyEar", 1.0)

	addPart(ANY_GENDER, "LongTail", 1.0)
	addPart(ANY_GENDER, "FluffyTail", 0.5)
	addPart(ANY_GENDER, "HugeFluffyTail", 0.2)

func getCharacterCreatorPartsTemplate(_gender:int) -> Dictionary:
	var result:Dictionary = {
		BodypartSlot.Body: {
			id = "FeminineBody",
			data = {
				legType = "digi",
				vagina = Gender.shouldHaveVaginaByDefault(_gender),
			},
			#skinType = SkinType.Fur,
		},
		BodypartSlot.Head: {
			id = "CanineHead",
		},
		BodypartSlot.Hair: {
			id = "Ponytail1",
		},
		BodypartSlot.LeftEar: {
			id = "FluffyEar",
		},
		BodypartSlot.RightEar: {
			id = "FluffyEar",
		},
		BodypartSlot.Tail: {
			id = "LongTail",
		},
	}
	if(_gender in [Gender.Male, Gender.Androgynous]):
		result[BodypartSlot.Penis] = {
			id = "CaninePenis",
		}
	return result
