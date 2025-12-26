extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2

func _init() -> void:
	id = "SexCowgirl"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	
	addAnimLibrary("sex", "res://Anims/Raw/SexCowgirl.glb")
	
	addState("tease", {
		dom = "sex/SexTease_1",
		sub = "sex/SexTease_2",
	}, {
		CONF_BASESPEED: 1.0,
		#CONF_HIDETAGS: {
			#dom = [SexHideTag.ArmRestraint],
			#sub = [SexHideTag.ArmRestraint],
		#},
	})
	addState("slow", {
		dom = "sex/SexSlow_1",
		sub = "sex/SexSlow_2",
	}, {
		CONF_BASESPEED: 0.7,
		CONF_SPEEDMULT_MIN: 0.9,
		CONF_SPEEDMULT_MAX: 1.1,
		CONF_TIMEDSPEEDSWITCH_MIN: 5.0,
		CONF_TIMEDSPEEDSWITCH_MAX: 10.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(12, "plap"),
		],
		#CONF_HIDETAGS: {
			#dom = [SexHideTag.ArmRestraint],
			#sub = [SexHideTag.ArmRestraint],
		#},
	})
	addState("sex", {
		dom = "sex/Sex_1",
		sub = "sex/Sex_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_SPEEDMULT_MIN: 0.9,
		CONF_SPEEDMULT_MAX: 1.1,
		CONF_TIMEDSPEEDSWITCH_MIN: 5.0,
		CONF_TIMEDSPEEDSWITCH_MAX: 10.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(11, "plap"),
		],
		#CONF_HIDETAGS: {
			#dom = [SexHideTag.ArmRestraint],
			#sub = [SexHideTag.ArmRestraint],
		#},
	})
	addState("fast", {
		dom = "sex/SexFast_1",
		sub = "sex/SexFast_2",
	}, {
		CONF_BASESPEED: 1.5,
		CONF_SPEEDMULT_MIN: 0.8,
		CONF_SPEEDMULT_MAX: 1.1,
		CONF_TIMEDSPEEDSWITCH_MIN: 3.0,
		CONF_TIMEDSPEEDSWITCH_MAX: 10.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(8, "plap"),
		],
		#CONF_HIDETAGS: {
			#dom = [SexHideTag.ArmRestraint],
			#sub = [SexHideTag.ArmRestraint],
		#},
	})
	addState("inside", {
		dom = "sex/SexInside_1",
		sub = "sex/SexInside_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_SPEEDMULT_MIN: 0.8,
		CONF_SPEEDMULT_MAX: 1.1,
		CONF_TIMEDSPEEDSWITCH_MIN: 3.0,
		CONF_TIMEDSPEEDSWITCH_MAX: 10.0,
		#CONF_ANIMEVENTS: [
		#],
		#CONF_HIDETAGS: {
			#dom = [SexHideTag.ArmRestraint],
			#sub = [SexHideTag.ArmRestraint],
		#},
	})
	addState("cum", {
		dom = "sex/Orgasm_1",
		sub = "sex/Orgasm_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			#animEventOnFrame(7, "plap"),
			animEventOnFrame(10, "cumInsideSound"),
			animEventOnFrame(22, "cumInsideSound"),
			#animEventOnFrame(30, "plap"),
			animEventOnFrame(35, "cumInsideSound"),
			#animEventOnFrame(77, "plap"),
			animEventOnFrame(60, "cumInsideSound"),
			animEventOnFrame(92, "cumInsideSound"),
		],
		#CONF_HIDETAGS: {
			#dom = [SexHideTag.ArmRestraint],
			#sub = [SexHideTag.ArmRestraint],
		#},
	})
	addState("teaseToSlow", {
		dom = "sex/SexTeaseToSlow_1",
		sub = "sex/SexTeaseToSlow_2",
	}, {
		CONF_BASESPEED: 1.0,
	})
	addState("slowToTease", {
		dom = "sex/SexSlowToTease_1",
		sub = "sex/SexSlowToTease_2",
	}, {
		CONF_BASESPEED: 1.0,
	})
	
	connectStates("tease", "teaseToSlow", 0.2, true)
	connectStates("teaseToSlow", "inside", 0.4, true, true)
	
	#connectStates("inside", "tease", 0.8, true)
	connectStates("inside", "slowToTease", 0.4, true)
	connectStates("slowToTease", "tease", 0.2, true, true)
	
	#connectStates("inside", "slow", 0.5)
	
	#connectStates("tease", "teaseToSlow", 0.2, true)
	connectStates("teaseToSlow", "slow", 0.2, true, true)
	connectStates("slow", "slowToTease", 0.2, true)
	#connectStates("slow", "tease", 0.8, true)
	#connectStates("tease", "slow", 1.2)
	
	connectStates("slow", "sex", 1.0)
	connectStates("sex", "fast", 0.6)
	
	connectStates("slow", "inside", 0.8)
	connectStates("sex", "inside", 0.8)
	connectStates("fast", "inside", 0.8)
	
	connectStates("slow", "cum", 0.5, true)
	connectStates("sex", "cum", 0.5, true)
	connectStates("fast", "cum", 0.5, true)
	connectStates("cum", "inside", 1.5, true, true)
	
	addAdditiveOneshot("bottomCum", {
		dom = "sex/FemOrgasm_1",
		sub = "sex/FemOrgasm_2",
	}, {
		dom = "sex/FemOrgasmBase_1",
		sub = "sex/FemOrgasmBase_2",
	}, {
		CONF_ANIMEVENTS: [
			animEventOnFrame(0, "squirt"),
			animEventOnFrame(5, "squirt"),
			animEventOnFrame(15, "squirt"),
			animEventOnFrame(45, "squirt"),
		],
	})
	
	setStartState("tease")
	
	updateAllAnimTrees()

func onAnimationEvent(_eventID:String):
	if(_eventID == "cumInsideSound"):
		doCumInsideNoise("dom", "sub")
		#doCumInsideEffect("dom", "sub")
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
		#doSquirtVagina("sub")
		doSquirtVagina("sub", 0.4, 0.6, 2.0, 15.0, -70.0)
		doCumOutsideEffect("sub")
	
func onPlayState(_state:String, _args:Dictionary):
	super.onPlayState(_state, _args)
	if(_state != "tease"):
		var theHole:int = _args["hole"] if _args.has("hole") else AnimSceneHole.Anus
		alignPenisToSitterHole("dom", "sub", theHole)
	else:
		alignPenisReset("dom")

func onOneShot(_oneshotID:String):
	if(_oneshotID == "bottomCum"):
		doOrgasmNoise("sub")
		#doSquirtVagina("sub", 20.0, 0.3, 10.0)
		#doSquirtVagina("sub")
		#await get_tree().create_timer(0.5).timeout
		#doSquirtVagina("sub", 0.1, 0.3, 2.0, 15.0)
	
