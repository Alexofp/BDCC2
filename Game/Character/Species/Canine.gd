extends SpeciesBase

func _init() -> void:
	id = "Canine"

func getName() -> String:
	return "Canine"

func getCharacterCreatorPartsTemplate(_gender:int) -> Dictionary:
	var result:Dictionary = {
		BodypartSlot.Body: {
			id = "FeminineBody",
			data = {
				legType = "digi",
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
