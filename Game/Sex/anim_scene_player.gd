extends Node3D
class_name AnimScenePlayer

@onready var anim_scene_spawner: AnimSceneSpawner = %AnimSceneSpawner

var animID:String = ""
var state:String = ""

signal onSceneSwitched
signal onAnimEvent(animID, state, eventID, args)
signal onAnimPlay(animID, state)

@rpc("authority", "call_remote", "reliable")
func playOneShot_RPC(oneshotID:String):
	if(anim_scene_spawner.isSpawned()):
		anim_scene_spawner.getScene().playOneShot(oneshotID)

func playOneShot(oneshotID:String):
	playOneShot_RPC(oneshotID)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(playOneShot_RPC, [oneshotID])

@rpc("authority", "call_remote", "reliable")
func playAnim_RPC(theAnimID:String, theStateID:String, thePawns:Dictionary):
	if(animID == theAnimID && state == theStateID):
		return
	animID = theAnimID
	state = theStateID
	if(animID == ""):
		return
	if(anim_scene_spawner.isSpawned()):
		anim_scene_spawner.getScene().playState(state)
		
		for role in thePawns:
			var pawnInfo:Dictionary = thePawns[role]
			if(pawnInfo.has("guidePenisVag")):
				anim_scene_spawner.getScene().alignPenisToSitterHole(role, pawnInfo["guidePenisVag"], AnimSceneBase.HOLE_VAGINA)
			elif(pawnInfo.has("guidePenisAnus")):
				anim_scene_spawner.getScene().alignPenisToSitterHole(role, pawnInfo["guidePenisAnus"], AnimSceneBase.HOLE_ANUS)
			else:
				anim_scene_spawner.getScene().alignPenisReset(role)
	#playAnim(theAnimID, theStateID, thePawns)

func playAnim(theAnimID:String, theStateID:String, thePawns:Dictionary):
	# TODO Check pawns
	#if(animID == theAnimID && state == theStateID):
		#sitPawns(thePawns)
		#return
	if(animID == theAnimID):# && state != theStateID):
		# TODO play on current
		state = theStateID
		sitPawns(thePawns)
		anim_scene_spawner.getScene().playState(state)
		if(Network.isServerNotSingleplayer()):
			Network.rpcClients(playAnim_RPC, [theAnimID, theStateID, thePawns])
		return
	
	if(animID != theAnimID):
		anim_scene_spawner.despawn()
	animID = theAnimID
	state = theStateID
	
	if(animID == ""):
		return

	var animRef:AnimDefBase = GlobalRegistry.getAnimScene(animID)
	var animPath:String = animRef.getScenePath()
	
	anim_scene_spawner.setScenePath(animPath)
	anim_scene_spawner.spawn()
	
	sitPawns(thePawns)
	anim_scene_spawner.getScene().playState(state, true)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(playAnim_RPC, [theAnimID, theStateID, thePawns])

func sitPawns(thePawns:Dictionary):
	if(!anim_scene_spawner.isSpawned()):
		return
	
	if(Network.isServer()):
		for role in thePawns:
			var thePawn:CharacterPawn = thePawns[role]["pawn"]
			
			if(anim_scene_spawner.getSitter(role) != thePawn):
				anim_scene_spawner.setSitter(role, thePawn)

	if(anim_scene_spawner.isSpawned()):
		for role in thePawns:
			var pawnInfo:Dictionary = thePawns[role]
			if(pawnInfo.has("guidePenisVag")):
				anim_scene_spawner.getScene().alignPenisToSitterHole(role, pawnInfo["guidePenisVag"], AnimSceneBase.HOLE_VAGINA)
			elif(pawnInfo.has("guidePenisAnus")):
				anim_scene_spawner.getScene().alignPenisToSitterHole(role, pawnInfo["guidePenisAnus"], AnimSceneBase.HOLE_ANUS)
			else:
				anim_scene_spawner.getScene().alignPenisReset(role)

func _on_anim_scene_spawner_on_anim_event(eventID: String, args: Variant) -> void:
	onAnimEvent.emit(animID, state, eventID, args)

func _on_anim_scene_spawner_on_spawned_changed(isSpawned: Variant) -> void:
	if(isSpawned):
		onSceneSwitched.emit()

func _on_anim_scene_spawner_on_anim_play(theState: String) -> void:
	onAnimPlay.emit(animID, theState)

func getAnimScene() -> AnimSceneBase:
	if(!anim_scene_spawner.isSpawned()):
		return null
	return anim_scene_spawner.getScene()

func getSexHideTagsFor(_charID:String) -> Array:
	if(!anim_scene_spawner.isSpawned()):
		return []
	return anim_scene_spawner.getScene().getSexHideTagsFor(_charID)

func saveNetworkData() -> Dictionary:
	return {
		animID = animID,
		state = state,
		scene = anim_scene_spawner.saveNetworkedData(),
	}

func loadNetworkData(_data:Dictionary):
	animID = SAVE.loadVar(_data, "animID", "")
	state = SAVE.loadVar(_data, "state", "")
	anim_scene_spawner.loadNetworkData(SAVE.loadVar(_data, "scene", {}))
	
