extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2

func _init() -> void:
	id = "AgainstWallSexPinned"
	
	animLibs = ["AgainstWallSexPinned"]

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	
	addState("tease", {
		dom = "AgainstWallSexPinned/Tease_1",
		sub = "AgainstWallSexPinned/Tease_2",
	}).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		#sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("slow", {
		dom = "AgainstWallSexPinned/Slow_1",
		sub = "AgainstWallSexPinned/Slow_2",
	}).setSpeedAutoSwitch(0.9, 1.1, 5.0, 10.0).setAnimEvents([
		animEventOnFrame(17, "plap"),
	]).setHideTags({
		dom = [SexHideTag.ArmRestraint],
		sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		#sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("sex", {
		dom = "AgainstWallSexPinned/Sex_1",
		sub = "AgainstWallSexPinned/Sex_2",
	}).setSpeedAutoSwitch(0.9, 1.1, 5.0, 10.0).setAnimEvents([
		animEventOnFrame(9, "plap"),
	]).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		#sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("fast", {
		dom = "AgainstWallSexPinned/Fast_1",
		sub = "AgainstWallSexPinned/Fast_2",
	}).setSpeedAutoSwitch(0.8, 1.1, 3.0, 10.0).setAnimEvents([
		animEventOnFrame(7, "plap"),
	]).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		#sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("inside", {
		dom = "AgainstWallSexPinned/Inside_1",
		sub = "AgainstWallSexPinned/Inside_2",
	}).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		#sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("cum", {
		dom = "AgainstWallSexPinned/Cum_1",
		sub = "AgainstWallSexPinned/Cum_2",
	}).setAnimEvents([
			animEventOnFrame(9, "plap"),
			animEventOnFrame(12, "cumInsideSound"),
			animEventOnFrame(22, "cumInsideSound"),
			animEventOnFrame(45, "plap"),
			animEventOnFrame(48, "cumInsideSound"),
			animEventOnFrame(80, "cumInsideSound"),
			animEventOnFrame(130, "plap"),
			animEventOnFrame(140, "cumInsideSound"),
	]).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		#sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	
	connectStates("tease", "inside", 0.5)
	connectStates("tease", "slow", 0.5)
	connectStates("slow", "sex", 0.5)
	connectStates("sex", "fast", 0.5)
	
	connectStates("slow", "inside", 0.5)
	connectStates("sex", "inside", 0.5)
	connectStates("fast", "inside", 0.5)
	
	connectStates("slow", "cum", 0.5, true)
	connectStates("sex", "cum", 0.5, true)
	connectStates("fast", "cum", 0.5, true)
	connectStates("cum", "inside", 1.0, true, true)
	
	addExtraLayer(AnimSceneExtraLayerOneshot.create("bottomCum", {
		dom = "AgainstWallSexPinned/BottomCum_1",
		sub = "AgainstWallSexPinned/BottomCum_2",
	}, {
		dom = "AgainstWallSexPinned/BottomCumBase_1",
		sub = "AgainstWallSexPinned/BottomCumBase_2",
	}).setAnimEvents([
			animEventOnFrame(0, "squirt"),
			animEventOnFrame(5, "squirt"),
			animEventOnFrame(15, "squirt"),
			animEventOnFrame(45, "squirt"),
	]))
	
	setStartState("tease")

func onAnimationEvent(_eventID:String):
	if(_eventID == "cumInsideSound"):
		doCumInsideNoise("dom", "sub")
		doCumInsideEffect("dom", "sub")
	if(_eventID == "plap"):
		doPlap("dom", "sub")
		doSquirtVagina("sub", RNG.randfRange(-0.3, 0.3), 0.2, 1.0, 45.0)
		if(getState() == "fast"):
			doMoan("sub", SexSoundSpeed.Fast, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 0)
		elif(getState() == "slow"):
			doMoan("sub", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 0)
		elif(getState() == "cum"):
			doMoan("sub", SexSoundSpeed.Medium, SexSoundMouth.Opened if RNG.chance(70) else SexSoundMouth.Closed, 0)
		else:
			doMoan("sub", SexSoundSpeed.Medium, SexSoundMouth.Opened if RNG.chance(70) else SexSoundMouth.Closed, 1 if RNG.chance(70) else 3)
	if(_eventID == "moan"):
		doMoan("sub", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 0)
	if(_eventID == "squirt"):
		doSquirtVagina("sub")
		doSquirtVagina("sub", 0.1, 0.3, 2.0, 15.0)
		doCumOutsideEffect("sub")

func onPlayState(_state:String, _args:Dictionary):
	super.onPlayState(_state, _args)
	if(_state != "tease"):
		var theHole:int = _args["hole"] if _args.has("hole") else AnimSceneHole.Anus
		alignPenisToSitterHole("dom", "sub", theHole)
	else:
		#alignPenisToPenisGuides("dom")
		alignPenisReset("dom")

func onOneShot(_oneshotID:String):
	if(_oneshotID == "bottomCum"):
		doOrgasmNoise("sub")
		#doSquirtVagina("sub", 20.0, 0.3, 10.0)
		#doSquirtVagina("sub")
		#await get_tree().create_timer(0.5).timeout
		#doSquirtVagina("sub", 0.1, 0.3, 2.0, 15.0)
