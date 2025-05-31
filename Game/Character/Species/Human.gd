extends SpeciesBase

func _init() -> void:
	id = "Human"

func getName() -> String:
	return "Human"

func getCharacterCreatorPartsTemplate(_gender:int) -> Dictionary:
	return {
		BodypartSlot.Body: {
			id = "FeminineBody",
		},
		BodypartSlot.Head: {
			id = "HumanFeminineHead",
		},
		BodypartSlot.Hair: {
			id = "Ponytail1",
		},
	}
