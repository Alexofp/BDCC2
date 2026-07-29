extends SpeciesBase

func _init() -> void:
	id = "Human"

func getName() -> String:
	return "Human"

func registerTraits():
	addTrait(SpeciesTrait.BodyNoBodySkin, 1.0)
	addTrait(SpeciesTrait.LegsPlanti, 1.0)

func getCharacterCreatorPartsTemplate(_gender:int) -> Dictionary:
	return {
		BodypartSlot.Body: {
			id = "FeminineBody",
			data = {
				legType = "planti",
				vagina = Gender.shouldHaveVaginaByDefault(_gender),
			},
		},
		BodypartSlot.Head: {
			id = "HumanFeminineHead",
		},
		BodypartSlot.Hair: {
			id = "Ponytail1",
		},
	}
