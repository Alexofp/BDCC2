extends DollPart

const SUIT = {
	color = Color.WHITE,
	albedo = "res://Mesh/Clothing/LatexSuit/Textures/LatexSuitAlbedo.png",
	normal = "res://Mesh/Clothing/LatexSuit/Textures/LatexSuitNormal.png",
	orm = "res://Mesh/Clothing/LatexSuit/Textures/LatexSuitORM.png",
	rim = 50.0,
	rim_tint = 0.0,
}

func gatherPartFlags(_theFlags:Dictionary):
	_theFlags["HidePenis"] = true
	_theFlags["HideNipples"] = true
	_theFlags["HideVagina"] = true

func getExtraLayerData() -> Dictionary:
	return SUIT
