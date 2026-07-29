extends SpeciesBase

func _init() -> void:
	id = "Feline"

func getName() -> String:
	return "Feline"

func registerTraits():
	addTrait(SpeciesTrait.LegsDigi, 1.0)
	addTrait(SpeciesTrait.HandsPaws, 0.7)

func registerAllowedParts():
	registerDefaultBodies()
	
	addPart(ANY_GENDER, "FluffyEar", 1.0)
	addPart(ANY_GENDER, "RoundEar", 0.5)
	addPart(ANY_GENDER, "SmallEar", 0.4)
	
	addPart(ANY_GENDER, "LongTail", 1.0)
	addPart(ANY_GENDER, "PaintbrushTail", 0.5)
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
			id = "FelineHead",
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
