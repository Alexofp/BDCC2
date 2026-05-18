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
}

const MatToPath:Dictionary[int, String] = {
	Mats.BlackTiles: "res://Mesh/Textures/Tileable/Wall/black_tiles/BlackTilesWall.tres",
	Mats.ConcreteTiles: "res://Mesh/Textures/Tileable/Wall/concrete_tiles/ConcreteWall.tres",
	Mats.ConcreteTiles2: "res://Mesh/Textures/Tileable/Wall/concrete_tiles2/ConcreteTilesWall.tres",
	Mats.FabricTiles: "res://Mesh/Textures/Tileable/Wall/fabric_tiles/FabricTilesWall.tres",
	Mats.Hexagon: "res://Mesh/Textures/Tileable/Wall/hexagon/HexWall.tres",
	Mats.RustyMetal: "res://Mesh/Textures/Tileable/Wall/rusty_metal_7/RustyMetalWall.tres",
	Mats.PlainColor: "res://Mesh/Textures/Tileable/Wall/PlainColor/PlainColor.tres",
}

static func getEditorValuesList() -> Array[Array]:
	var result:Array[Array] = []
	for theMatIndx in MatToPath:
		var thePath:String = MatToPath[theMatIndx]
		result.append([
			thePath, thePath.get_file().get_basename(),
		])
	
	return result
