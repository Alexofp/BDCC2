extends Node
class_name SitManager

var pawnToSeat:Dictionary[CharacterPawn, PoseSpot] = {}
var seatToPawn:Dictionary[PoseSpot, CharacterPawn] = {}

func _ready() -> void:
	GameInteractor.sitManager = self

func connectSignals():
	GM.pawnRegistry.onPawnDeleted.connect(handleDeletionOfPawn)

func handleDeletionOfPawn(_pawn:CharacterPawn):
	if(isSitting(_pawn)):
		unsit(_pawn)

func handleDeletionOfSeat(_spot:PoseSpot):
	var _pawn:CharacterPawn = getPawnSittingOn(_spot)
	if(_pawn):
		unsit(_pawn)

func doSit(_pawn:CharacterPawn, _spot:PoseSpot):
	if(!_pawn):
		assert(false, "PAWN IS NULL")
		return
	if(!_spot):
		assert(false, "SPOT IS NULL")
		return
	if(isSitting(_pawn)):
		unsit(_pawn)
	if(hasPawnSittingOn(_spot)):
		freeSeat(_spot)
	pawnToSeat[_pawn] = _spot
	seatToPawn[_spot] = _pawn
	
	_pawn.onSeatChange(_spot)
	_spot.onPawnChange(_pawn)
	
	#print("MEOW MEOW MEOW "+str(pawnToSeat))
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(doSitRPC, [GameInteractor.getUniqueIDOf(_pawn), GameInteractor.getUniqueIDOf(_spot)])

@rpc("authority", "call_remote", "reliable")
func doSitRPC(_pawnID:Array, _spotID:Array):
	var thePawn = GameInteractor.getNodeByUniqueID(_pawnID)
	var theSpot = GameInteractor.getNodeByUniqueID(_spotID)
	if(!thePawn):
		Log.Printerr("Bad pawn id, "+str(_pawnID))
		return
	if(!theSpot):
		Log.Printerr("Bad spot id, "+str(_spotID))
		return
	doSit(thePawn, theSpot)

func unsit(_pawn:CharacterPawn):
	if(!_pawn):
		assert(false, "PAWN IS NULL")
		return
	var _spot := getSeatOfPawn(_pawn)
	if(!_spot):
		return
	pawnToSeat.erase(_pawn)
	seatToPawn.erase(_spot)
	
	_pawn.onSeatChange(null)
	_spot.onPawnChange(null)
	
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(doUnsitRPC, [GameInteractor.getUniqueIDOf(_pawn)])

@rpc("authority", "call_remote", "reliable")
func doUnsitRPC(_pawnID:Array):
	var thePawn = GameInteractor.getNodeByUniqueID(_pawnID)
	if(!thePawn):
		Log.Printerr("Bad pawn id, "+str(_pawnID))
	unsit(thePawn)

func doSitDoll(_doll:DollController, _spot:PoseSpot):
	doSit(_doll.getPawn(), _spot)

func unsitDoll(_doll:DollController):
	unsit(_doll.getPawn())

func freeSeat(_spot:PoseSpot):
	var _pawn:CharacterPawn = getPawnSittingOn(_spot)
	if(_pawn):
		unsit(_pawn)

func getSeatOfPawn(_pawn:CharacterPawn) -> PoseSpot:
	if(!_pawn):
		return null
	
	if(!pawnToSeat.has(_pawn)):
		return null
	return pawnToSeat[_pawn]

func getSeatOfDoll(_doll:DollController) -> PoseSpot:
	if(_doll):
		return getSeatOfPawn(_doll.getPawn())
	return null

func getPawnSittingOn(_spot:PoseSpot) -> CharacterPawn:
	if(!_spot):
		return null
	
	if(!seatToPawn.has(_spot)):
		return null
	return seatToPawn[_spot]

func getDollSittingOn(_spot:PoseSpot) -> DollController:
	var thePawn := getPawnSittingOn(_spot)
	if(thePawn):
		return thePawn.getDoll()
	return null

func isSitting(_pawn:CharacterPawn) -> bool:
	return getSeatOfPawn(_pawn) != null

func isSittingDoll(_doll:DollController) -> bool:
	return getSeatOfDoll(_doll) != null

func hasPawnSittingOn(_spot:PoseSpot) -> bool:
	return getPawnSittingOn(_spot) != null

func hasDollSittingOn(_spot:PoseSpot) -> bool:
	return getDollSittingOn(_spot) != null

func clear():
	pawnToSeat.clear()
	seatToPawn.clear()

func saveNetworkData() -> Dictionary:
	var sittersPairs:Array = []
	for pawn in pawnToSeat:
		var seat := pawnToSeat[pawn]
		sittersPairs.append([
			GameInteractor.getUniqueIDOf(pawn),
			GameInteractor.getUniqueIDOf(seat),
		])
	
	return {
		sitters = sittersPairs,
	}

func loadNetworkData(_data:Dictionary):
	clear()
	var sittersData:Array = SAVE.loadVar(_data, "sitters", [])
	
	for pair in sittersData:
		Log.Print("LOADING A SIT AAAAAAAAAAA: "+str(pair))
		doSitRPC(pair[0], pair[1])
	Log.Print("AAAAA "+str(pawnToSeat))
	Log.Print("AAAAA2 "+str(seatToPawn))
