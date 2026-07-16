@tool
extends Object
class_name TilableFloorMat

enum Mats {
	Custom, # Needs to have this to support custom mats for props
	BlackTiles,
	ConcreteTiles,
	ConcreteTiles2,
	FabricTiles,
	Hexagon,
	RustyMetal,
}

const MatToPath:Dictionary[int, String] = {
	Mats.BlackTiles: "res://Mesh/Textures/Tileable/black_tiles/BlackTiles.tres",
	Mats.ConcreteTiles: "res://Mesh/Textures/Tileable/concrete_tiles/ConcreteFloor.tres",
	Mats.ConcreteTiles2: "res://Mesh/Textures/Tileable/concrete_tiles2/ConcreteTiles.tres",
	Mats.FabricTiles: "res://Mesh/Textures/Tileable/fabric_tiles/FabricTiles.tres",
	Mats.Hexagon: "res://Mesh/Textures/Tileable/hexagon/HexFloor.tres",
	Mats.RustyMetal: "res://Mesh/Textures/Tileable/rusty_metal_7/RustyMetal.tres",
}

static func getEditorValuesList() -> Array[Array]:
	var result:Array[Array] = []
	for theMatIndx in MatToPath:
		var thePath:String = MatToPath[theMatIndx]
		result.append([
			thePath, thePath.get_file().get_basename(),
		])
	
	return result
