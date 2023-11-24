extends ClothingPart

func applyToDoll(_theDoll:Doll):
	setMeshToBodypartByPath($rig/Skeleton3D/Retopo_TshirtTest_001, [])

func getBodyAlphaTexturePath() -> String:
	return "res://Mesh/Parts/Body/FeminineBody/Textures/BodyAlphaTest2.png"
