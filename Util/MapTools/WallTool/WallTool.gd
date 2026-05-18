@tool
extends Node3D
class_name WallTool

const GRID_SIZE:float = 1.0

enum DIR{
	North = 1,
	South = 2,
	East = 4,
	West = 8,
}

class GridEntry:
	var blocked:int # Blocked directions, bit flags

var grid:Dictionary[Vector3i, GridEntry] = {}



static func convertToGridPos(_pos:Vector3) -> Vector3i:
	return Vector3i(int(round(_pos.x/GRID_SIZE)), int(round(_pos.y/GRID_SIZE)), int(round(_pos.z/GRID_SIZE)))

static func convertFromGridPos(_pos:Vector3i) -> Vector3:
	return Vector3(_pos.x*GRID_SIZE, _pos.y*GRID_SIZE, _pos.z*GRID_SIZE)

static func getOppositeDir(_dir:int) -> int:
	if(_dir == DIR.North):
		return DIR.South
	if(_dir == DIR.South):
		return DIR.North
	if(_dir == DIR.East):
		return DIR.West
	if(_dir == DIR.West):
		return DIR.East
	return DIR.North

static func getRotatedDir(_dir:int) -> int:
	if(_dir == DIR.North):
		return DIR.West
	if(_dir == DIR.South):
		return DIR.West
	if(_dir == DIR.East):
		return DIR.North
	if(_dir == DIR.West):
		return DIR.North
	return DIR.North

static func getDirName(_dir:int) -> String:
	var result:String = ""
	if(_dir & DIR.North):
		result += "North"
	if(_dir & DIR.South):
		result += "South"
	if(_dir & DIR.East):
		result += "East"
	if(_dir & DIR.West):
		result += "West"
	if(result.is_empty()):
		return "Unknown"+str(_dir)
	return result

static func getDirFromTR(_transform:Transform3D) -> int:
	var theRot:float = rad_to_deg(_transform.basis.get_euler().y)
	
	var angle:float = fmod(theRot, 360.0)
	if angle < 0:
		angle += 360.0

	if angle < 45 or angle >= 315:
		#return DIR.North
		return DIR.South
	elif angle < 135:
		#return DIR.East
		return DIR.East
	elif angle < 225:
		#return DIR.South
		return DIR.North
	else: # angle < 315
		#return DIR.West
		return DIR.West

static func applyDir(_pos:Vector3i, _dir:int, _amount:int = 1) -> Vector3i:
	if(_dir == DIR.North):
		_pos.z -= _amount
	elif(_dir == DIR.South):
		_pos.z += _amount
	elif(_dir == DIR.West):
		_pos.x -= _amount
	elif(_dir == DIR.East):
		_pos.x += _amount
	return _pos

static func getCellPos(_pos:Vector3i, _dir:int) -> Vector3i:
	if(_dir == DIR.North):
		_pos.z -= 1
	elif(_dir == DIR.South):
		pass
	elif(_dir == DIR.West):
		_pos.x -= 1
	elif(_dir == DIR.East):
		pass
	return _pos

func setBlocked(_pos:Vector3i, _dir:int):
	if(!grid.has(_pos)):
		var newEntry := GridEntry.new()
		newEntry.blocked = _dir
		grid[_pos] = newEntry
		return
	var theEntry := grid[_pos]
	theEntry.blocked |= _dir

func createWall() -> void:
	grid.clear()
	var allLines:Array[WallToolLine] = []
	for theChild in get_children():
		if(theChild is WallToolLine):
			allLines.append(theChild)
	
	for theLine in allLines:
		var theDir:int = getOppositeDir(getDirFromTR(theLine.transform))
		var thePoses := theLine.getAllAffectionPositions()
		
		for thePos in thePoses:
			setBlocked(thePos, theDir)
	
	for thePos in grid:
		print("POS: ",thePos," BLOCKED: ",getDirName(grid[thePos].blocked))
		
	
@export_tool_button("Make wall", "Callable") var createWall_action = createWall
