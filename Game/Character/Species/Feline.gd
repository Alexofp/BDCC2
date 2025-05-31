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
			},
			skinType = SkinType.Fur,
		},
		BodypartSlot.Head: {
			id = "FelineHead",
		},
		BodypartSlot.Hair: {
			id = "Ponytail1",
		},
		BodypartSlot.LeftEar: {
			id = "FelineEar",
		},
		BodypartSlot.RightEar: {
			id = "FelineEar",
		},
		BodypartSlot.Tail: {
			id = "FelineTail",
		},
	}
	if(_gender in [Gender.Male, Gender.Androgynous]):
		result[BodypartSlot.Penis] = {
			id = "CaninePenis",
		}
	return result
