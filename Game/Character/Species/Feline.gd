extends SpeciesBase

func _init() -> void:
	id = "Feline"

func getName() -> String:
	return "Feline"

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
