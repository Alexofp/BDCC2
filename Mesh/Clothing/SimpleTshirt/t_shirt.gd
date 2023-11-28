extends ClothingPart

func applyToDoll(_theDoll:Doll):
	setMeshToBodypartByPath($rig/Skeleton3D/Retopo_TshirtTest_001, [])

func getBodyAlphaTexturePath() -> String:
	return "res://Mesh/Clothing/SimpleTshirt/ShirtAlpha.png"

func getPartsToHide() -> Dictionary:
	return {
		ClothingHidePart.Nipples: true,
	}

func updateHiddenParts(_hiddenParts:Dictionary):
	pass
