@tool
extends Object
class_name TilableWallMat

enum Mats {
	Custom, # Needs to have this to support custom mats for props
	BlackTiles,
	ConcreteTiles,
	ConcreteTiles2,
	FabricTiles,
	Hexagon,
	RustyMetal,
	PlainColor,
	Concrete031,
	Concrete033,
}

const MatToPath:Dictionary[int, String] = {
	Mats.BlackTiles: "res://Mesh/Textures/Tileable/black_tiles/BlackTilesWall.tres",
	Mats.ConcreteTiles: "res://Mesh/Textures/Tileable/concrete_tiles/ConcreteWall.tres",
	Mats.ConcreteTiles2: "res://Mesh/Textures/Tileable/concrete_tiles2/ConcreteTilesWall.tres",
	Mats.FabricTiles: "res://Mesh/Textures/Tileable/fabric_tiles/FabricTilesWall.tres",
	Mats.Hexagon: "res://Mesh/Textures/Tileable/hexagon/HexWall.tres",
	Mats.RustyMetal: "res://Mesh/Textures/Tileable/rusty_metal_7/RustyMetalWall.tres",
	Mats.PlainColor: "res://Mesh/Textures/Tileable/PlainColor/PlainColor.tres",
	Mats.Concrete031: "res://Mesh/Textures/Tileable/Concrete031/Concrete031.tres",
	Mats.Concrete033: "res://Mesh/Textures/Tileable/Concrete033/Concrete033.tres",
}

static func getEditorValuesList() -> Array[Array]:
	var result:Array[Array] = []
	for theMatIndx in MatToPath:
		var thePath:String = MatToPath[theMatIndx]
		result.append([
			thePath, thePath.get_file().get_basename(),
		])
	
	return result
