extends ItemBase

func _init():
	id = "LatexSuit"

func getName() -> String:
	return "Latex suit"

func getSlot() -> int:
	return InventorySlot.Suit

func getOptions() -> Dictionary:
	return {
	}

func getSexHideTags() -> Dictionary:
	return {
		#SexHideTag.CoversBreasts: true,
		SexHideTag.CoversPenis: true,
		SexHideTag.CoversVagina: true,
		SexHideTag.CoversAnus: true,
	}
