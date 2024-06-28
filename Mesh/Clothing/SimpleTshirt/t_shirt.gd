extends ClothingPart

func applyToDoll(_theDoll:Doll, _dollPart:DollPart):
	setMeshToBodypartByPath($rig/Skeleton3D/Retopo_TshirtTest_001, [])

func getBodyAlphaTexturePath() -> String:
	return "res://Mesh/Clothing/SimpleTshirt/ShirtAlpha.png"

func getPartTags() -> Dictionary:
	return {
		PartTag.Body_HideNipples: true,
	}

func applyPartTags(_partTags:Dictionary):
	pass
