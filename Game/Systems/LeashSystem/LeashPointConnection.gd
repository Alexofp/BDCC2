extends RefCounted
class_name LeashPointConnection

const MODE_LEASHPOINT = 0
const MODE_PAWN_LEASHPOINT = 1

var mode:int = MODE_LEASHPOINT

var leashPoint:LeashPoint
#var pawnID:String = ""
var pawn:CharacterPawn
var pawnLeashPoint:String = ""

signal onLeashPointChange(newLeashPoint:LeashPoint)

static func createLeashpoint(_leashPoint:LeashPoint) -> LeashPointConnection:
	var theCon := LeashPointConnection.new()
	theCon.mode = MODE_LEASHPOINT
	theCon.leashPoint = _leashPoint
	return theCon

static func createPawnLeashpoint(_pawn:CharacterPawn, _pawnLeashPoint:String) -> LeashPointConnection:
	var theCon := LeashPointConnection.new()
	theCon.mode = MODE_PAWN_LEASHPOINT
	theCon.pawn = _pawn
	theCon.pawnLeashPoint = _pawnLeashPoint
	return theCon

func getCacheNode() -> Node3D:
	if(mode == MODE_LEASHPOINT):
		return leashPoint
	if(mode == MODE_PAWN_LEASHPOINT):
		return pawn
	return null

func isSameAs(_other:LeashPointConnection) -> bool:
	if(mode != _other.mode):
		return false
	
	if(mode == MODE_PAWN_LEASHPOINT):
		if(pawn != _other.pawn || pawnLeashPoint != _other.pawnLeashPoint):
			return false
	
	return true

func setLeashpoint(_lp:LeashPoint):
	#var theOldLP := leashPoint
	if(leashPoint == _lp):
		return
	leashPoint = _lp
	onLeashPointChange.emit(_lp)

func checkPoint():
	if(mode == MODE_LEASHPOINT):
		return
	if(mode == MODE_PAWN_LEASHPOINT):
		if(leashPoint!=null && !is_instance_valid(leashPoint)):
			setLeashpoint(null)
		
		if(true):#leashPoint == null):
			var thePawn := pawn#GM.pawnRegistry.getPawn(pawnID)
			if(!thePawn):
				return
			var theLeashPoint := thePawn.getLeashPoint(pawnLeashPoint)
			if(theLeashPoint):
				setLeashpoint(theLeashPoint)
		return

func getLeashPoint() -> LeashPoint:
	return leashPoint

func shouldConnectionBreak() -> bool:
	if(mode == MODE_PAWN_LEASHPOINT):
		if(!pawn):
			return true
		var theChar := pawn.getCharacter()
		if(theChar && !theChar.hasLeashingPoint(pawnLeashPoint)):
			return true
	elif(mode == MODE_LEASHPOINT):
		if(!leashPoint || !is_instance_valid(leashPoint)):
			return true
	return false

func saveNetworkData() -> Bins:
	var ar:Array = [
		Bins.U8, mode,
	]
	if(mode == MODE_LEASHPOINT):
		ar.append(Bins.StrShort)
		ar.append(str(leashPoint.get_path()))
	if(mode == MODE_PAWN_LEASHPOINT):
		ar.append_array([
			Bins.StrShort, pawn.getCharID() if pawn else "", Bins.StrShort, pawnLeashPoint,
		])
	
	return Bins.saveStartEnd(ar)

func loadNetworkData(_data:Bins):
	_data.loadStart()
	mode = _data.readU8()
	
	if(mode == MODE_LEASHPOINT):
		leashPoint = GlobalRegistry.get_tree().root.get_node_or_null(NodePath(_data.readStrShort()))
	if(mode == MODE_PAWN_LEASHPOINT):
		var _pawnID:String = _data.readStrShort()
		pawn = GM.pawnRegistry.getPawn(_pawnID)
		pawnLeashPoint = _data.readStrShort()
	_data.endLoad()

func saveData() -> Dictionary:
	var _data:Dictionary = {
		mode = mode,
	}
	if(mode == MODE_LEASHPOINT):
		_data["leashPoint"] = str(leashPoint.get_path())
	if(mode == MODE_PAWN_LEASHPOINT):
		_data["pawnID"] = pawn.getCharID() if pawn else ""
		_data["pawnLeashPoint"] = pawnLeashPoint
	return _data

func loadData(_data:Dictionary):
	mode = SAVE.loadVar(_data, "mode", MODE_LEASHPOINT)
	
	if(mode == MODE_LEASHPOINT):
		leashPoint = GlobalRegistry.get_tree().root.get_node_or_null(NodePath(SAVE.loadVar(_data, "leashPoint", "")))
	if(mode == MODE_PAWN_LEASHPOINT):
		var _pawnID:String = SAVE.loadVar(_data, "pawnID", "")
		pawn = GM.pawnRegistry.getPawn(_pawnID)
		pawnLeashPoint = SAVE.loadVar(_data, "pawnLeashPoint", "")
		
	pass
