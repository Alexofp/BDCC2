@tool
extends Marker3D
class_name WallToolLine

@export var width:int = 2
@export var height:int = 1

func getAllAffectionPositions() -> Array[Vector3i]:
	var ourPosition:Vector3i = WallTool.convertToGridPos(position)
	var ourDir:int = WallTool.getDirFromTR(transform)
	var theRotatedDir:int = WallTool.getRotatedDir(ourDir)
	var theOtherRotatedDir:int = WallTool.getOppositeDir(theRotatedDir)
	
	var result:Array[Vector3i] = []
	
	@warning_ignore("integer_division")
	var theStartPos:Vector3i = WallTool.applyDir(ourPosition, theRotatedDir, width/2)
	
	for _i in width:#+1:
		result.append(WallTool.getCellPos(theStartPos, ourDir))
		theStartPos = WallTool.applyDir(theStartPos, theOtherRotatedDir)
	
	return result

func doFindTiles() -> void:
	var ourPosition:Vector3i = WallTool.convertToGridPos(position)
	
	print(ourPosition," ", WallTool.getDirName(WallTool.getDirFromTR(transform)))
	print(getAllAffectionPositions())
	

@export_tool_button("TEST", "Callable") var doTest_action = doFindTiles
