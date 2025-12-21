extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2

func _init() -> void:
	id = "Tribadism"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	
	addAnimLibrary("sex", "res://Anims/Raw/Tribadism.glb")
	
	addState("tease", {
		dom = "sex/TribTease_1",
		sub = "sex/TribTease_2",
	}, {
		CONF_BASESPEED: 1.0,
	})
	addState("slow", {
		dom = "sex/TribSlow_1",
		sub = "sex/TribSlow_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(2, "moanSub"),
			animEventOnFrame(35, "moan"),
		],
		#CONF_HIDETAGS: {
		#	dom = [SexHideTag.ArmRestraint],
		#},
	})
	addState("sex", {
		dom = "sex/Trib_1",
		sub = "sex/Trib_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(2, "moanSub"),
			animEventOnFrame(5, "moan"),
		],
	})
	addState("fast", {
		dom = "sex/TribFast_1",
		sub = "sex/TribFast_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(2, "moanSub"),
			animEventOnFrame(3, "moan"),
		],
	})
	addState("orgasmBoth", {
		dom = "sex/TribOrgasm_1",
		sub = "sex/TribOrgasm_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(1, "orgasmSub"),
			animEventOnFrame(5, "orgasm"),
			animEventOnFrame(10, "squirt2"),
			animEventOnFrame(20, "squirt1"),
			animEventOnFrame(23, "squirt2"),
			animEventOnFrame(33, "squirt1"),
			animEventOnFrame(45, "squirt2"),
			animEventOnFrame(55, "squirt1"),
			animEventOnFrame(68, "squirt2"),
			animEventOnFrame(88, "squirt1"),
			animEventOnFrame(121, "squirt2"),
			animEventOnFrame(111, "squirt1"),
		],
	})
	addState("orgasm1", {
		dom = "sex/TribOrgasm_1",
		sub = "sex/TribOrgasmIdle_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			#animEventOnFrame(1, "orgasmSub"),
			animEventOnFrame(1, "orgasm"),
			animEventOnFrame(10, "squirt1"),
			animEventOnFrame(33, "squirt1"),
			animEventOnFrame(55, "squirt1"),
			animEventOnFrame(88, "squirt1"),
			animEventOnFrame(111, "squirt1"),
		],
	})
	addState("orgasm2", {
		dom = "sex/TribOrgasmIdle_1",
		sub = "sex/TribOrgasm_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(1, "orgasmSub"),
			#animEventOnFrame(1, "orgasm"),
			animEventOnFrame(10, "squirt2"),
			animEventOnFrame(33, "squirt2"),
			animEventOnFrame(55, "squirt2"),
			animEventOnFrame(88, "squirt2"),
			animEventOnFrame(111, "squirt2"),
		],
	})
	
	setStartState("tease")
	
	connectStates("tease", "slow", 0.7)
	connectStates("slow", "sex", 0.7)
	connectStates("sex", "fast", 0.7)
	
	for orgasmID in ["orgasmBoth", "orgasm1", "orgasm2"]:
		connectStates("tease", orgasmID, 0.4, true)
		connectStates("slow", orgasmID, 0.4, true)
		connectStates("fast", orgasmID, 0.4, true)
		connectStates("sex", orgasmID, 0.4, true)
		connectStates(orgasmID, "tease", 1.0, true, true)
	
	updateAllAnimTrees()

const SQUIRT_ANGLE = -40.0

func onAnimationEvent(_eventID:String):
	if(_eventID == "orgasm"):
		doOrgasmNoise("dom")
	if(_eventID == "orgasmSub"):
		doOrgasmNoise("sub")
	if(_eventID == "squirtBoth"):
		#doSquirtVagina("dom", )
		doSquirtVagina("dom", 0.5, 1.0, 1.0, 15.0, SQUIRT_ANGLE)
		#doSquirtVagina("sub")
		doSquirtVagina("sub", 0.5, 1.0, 1.0, 15.0, SQUIRT_ANGLE)
	if(_eventID == "squirt1"):
		#doSquirtVagina("dom")
		doSquirtVagina("dom", 0.5, 1.0, 1.0, 15.0, SQUIRT_ANGLE)
	if(_eventID == "squirt2"):
		#doSquirtVagina("sub")
		doSquirtVagina("sub", 0.5, 1.0, 1.0, 15.0, SQUIRT_ANGLE)
	if(_eventID == "moan"):
		if(RNG.chance(10)):
			doSquirtVagina("dom", RNG.randfRange(0.1, 0.1), 0.2, 1.0, 25.0, SQUIRT_ANGLE)
		if(getState() in ["fast", "orgasm1", "orgasm2", "orgasmBoth"]):
			if(RNG.chance(50)):
				doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 1)
		elif(getState() == "sex"):
			if(RNG.chance(50)):
				doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 1)
		elif(getState() == "slow"):
			if(RNG.chance(25)):
				doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(25) else SexSoundMouth.Closed, 1)
	if(_eventID == "moanSub"):
		if(RNG.chance(10)):
			doSquirtVagina("sub", RNG.randfRange(0.1, 0.1), 0.2, 1.0, 25.0, SQUIRT_ANGLE)
		if(getState() in ["fast", "orgasm1", "orgasm2", "orgasmBoth"]):
			doMoan("sub", SexSoundSpeed.Medium, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 1)
		elif(getState() == "sex"):
			doMoan("sub", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 1)
		elif(getState() == "slow"):
			doMoan("sub", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(25) else SexSoundMouth.Closed, 1)
	
	#if(_eventID == "shootcum"):
	#	doCumOutsideEffect("dom")
