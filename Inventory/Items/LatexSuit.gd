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

func isBondageGear() -> bool:
	return true

func canUnequipInSex(_context:Dictionary) -> bool:
	return true

func getCoveredZones() -> Dictionary[int, bool]:
	return {
		#ZoneCover.Anything: true,
		ZoneCover.Body: true,
		ZoneCover.Breasts: true,
		ZoneCover.Nipples: true,
		ZoneCover.Penis: true,
		ZoneCover.Vagina: true,
		ZoneCover.Anus: true,
	}
