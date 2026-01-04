extends Node
class_name SitManager

var pawnToSeat:Dictionary[CharacterPawn, PoseSpot] = {}
var seatToPawn:Dictionary[PoseSpot, CharacterPawn] = {}

var propToSpot:Dictionary[Node3D, PropSpot]
var spotToProp:Dictionary[PropSpot, Node3D]

func _ready() -> void:
	GI.sitManager = self

func connectSignals():
	GM.pawnRegistry.onPawnDeleted.connect(handleDeletionOfPawn)

func handleDeletionOfPawn(_pawn:CharacterPawn):
	if(isSitting(_pawn)):
		unsit(_pawn)

func handleDeletionOfSeat(_spot:PoseSpot):
	freeSeat(_spot)

# ==== Prop Handling START
func handleDeletionOfPropSpot(_spot:PropSpot):
	freePropSpot(_spot)

func getSpotOfProp(_prop:Node3D) -> PropSpot:
	if(!_prop):
		return null
	if(!propToSpot.has(_prop)):
		return null
	return propToSpot[_prop]

func isPropAttachedToSpot(_prop:Node3D) -> bool:
	return getSpotOfProp(_prop) != null

func unattachProp(_prop:Node3D):
	if(!_prop):
		assert(false, "PROP IS NULL")
		return
	var _spot := getSpotOfProp(_prop)
	if(!_spot):
		return
	propToSpot.erase(_prop)
	spotToProp.erase(_spot)
	
	if(_prop.has_method("onPropSpotChanged")):
		_prop.onPropSpotChanged(null)
	_spot.onPropChange(null)
	
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(unattachProp_RPC.bind(GI.getUniqueIDOf(_prop)))

@rpc("authority", "call_remote", "reliable")
func unattachProp_RPC(_pawnID:Array):
	var theProp = GI.getNodeByUniqueID(_pawnID)
	if(!theProp):
		Log.Printerr("Bad PROP id, "+str(_pawnID))
	unattachProp(theProp)

func getPropAttachedToSpot(_spot:PropSpot) -> Node3D:
	if(!_spot):
		return null
	
	if(!spotToProp.has(_spot)):
		return null
	return spotToProp[_spot]

func hasPropAttachToSpot(_spot:PropSpot) -> bool:
	return getPropAttachedToSpot(_spot) != null

func freePropSpot(_spot:PropSpot):
	var _prop := getPropAttachedToSpot(_spot)
	if(_prop):
		unattachProp(_prop)

func setProp(_prop:Node3D, _spot:PropSpot):
	if(!_prop):
		assert(false, "PROP IS NULL")
		return
	if(!_spot):
		assert(false, "SPOT IS NULL")
		return
	if(isPropAttachedToSpot(_prop)):
		unattachProp(_prop)
	if(hasPropAttachToSpot(_spot)):
		freePropSpot(_spot)
	propToSpot[_prop] = _spot
	spotToProp[_spot] = _prop
	
	if(_prop.has_method("onPropSpotChanged")):
		_prop.onPropSpotChanged(_spot)
	_spot.onPropChange(_prop)
	
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(setProp_RPC.bind(GI.getUniqueIDOf(_prop), GI.getUniqueIDOf(_spot)))

@rpc("authority", "call_remote", "reliable")
func setProp_RPC(_pawnID:Array, _spotID:Array):
	var theProp = GI.getNodeByUniqueID(_pawnID)
	var theSpot = GI.getNodeByUniqueID(_spotID)
	if(!theProp):
		Log.Printerr("Bad PROP id, "+str(_pawnID))
		return
	if(!theSpot):
		Log.Printerr("Bad spot id, "+str(_spotID))
		return
	setProp(theProp, theSpot)
	
# ==== Prop Handling END

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
		Network.rpcClients(doSitRPC.bind(GI.getUniqueIDOf(_pawn), GI.getUniqueIDOf(_spot)))

@rpc("authority", "call_remote", "reliable")
func doSitRPC(_pawnID:Array, _spotID:Array):
	var thePawn = GI.getNodeByUniqueID(_pawnID)
	var theSpot = GI.getNodeByUniqueID(_spotID)
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
		Network.rpcClients(doUnsitRPC.bind(GI.getUniqueIDOf(_pawn)))

@rpc("authority", "call_remote", "reliable")
func doUnsitRPC(_pawnID:Array):
	var thePawn = GI.getNodeByUniqueID(_pawnID)
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
	propToSpot.clear()
	spotToProp.clear()

func saveNetworkData() -> Bins:
	var Ar:Array = [
		Bins.I32, pawnToSeat.size(),
		Bins.I32, propToSpot.size(),
	]
	for pawn in pawnToSeat:
		var seat := pawnToSeat[pawn]
		Ar.append_array([Bins.Var, GI.getUniqueIDOf(pawn)])
		Ar.append_array([Bins.Var, GI.getUniqueIDOf(seat)])
	for prop in propToSpot:
		var theSpot := propToSpot[prop]
		Ar.append_array([Bins.Var, GI.getUniqueIDOf(prop)])
		Ar.append_array([Bins.Var, GI.getUniqueIDOf(theSpot)])
	
	return Bins.saveStartEnd(Ar)

func loadNetworkData(_data:Bins):
	clear()
	_data.loadStart()
	var theAm:int = _data.readI32()
	var thePropAm:int = _data.readI32()
	
	for _i in range(theAm):
		var pair1 = _data.readVar()
		var pair2 = _data.readVar()
		doSitRPC(pair1, pair2)
	
	for _i in range(thePropAm):
		var pair1 = _data.readVar()
		var pair2 = _data.readVar()
		setProp_RPC(pair1, pair2)
	_data.endLoad()

func saveData() -> Dictionary:
	var sittersPairs:Array = []
	for pawn in pawnToSeat:
		var seat := pawnToSeat[pawn]
		sittersPairs.append([
			GI.getUniqueIDOf(pawn),
			GI.getUniqueIDOf(seat),
		])
	var propPairs:Array = []
	for prop in propToSpot:
		var theSpot := propToSpot[prop]
		propPairs.append([
			GI.getUniqueIDOf(prop),
			GI.getUniqueIDOf(theSpot),
		])
	
	return {
		sitters = sittersPairs,
		props = propPairs,
	}

func loadData(_data:Dictionary):
	clear()
	var sittersData:Array = SAVE.loadVar(_data, "sitters", [])
	var propsData:Array = SAVE.loadVar(_data, "props", [])
	
	for pair in sittersData:
		doSitRPC(pair[0], pair[1])
	for pair in propsData:
		setProp_RPC(pair[0], pair[1])
