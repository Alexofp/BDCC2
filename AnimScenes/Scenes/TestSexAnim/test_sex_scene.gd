extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	
	addAnimLibrary("sex", "res://Anims/Raw/SexStandingAnims.glb")
	
	addState("tease", {
		dom = "sex/SexStandingTease_1",
		sub = "sex/SexStandingTease_2",
	}, {
		CONF_BASESPEED: 1.0,
	})
	addState("slow", {
		dom = "sex/SexStandingSlow_1",
		sub = "sex/SexStandingSlow_2",
	}, {
		CONF_BASESPEED: 0.7,
		CONF_SPEEDMULT_MIN: 0.9,
		CONF_SPEEDMULT_MAX: 1.1,
		CONF_TIMEDSPEEDSWITCH_MIN: 5.0,
		CONF_TIMEDSPEEDSWITCH_MAX: 10.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(7, "plap"),
		],
	})
	addState("sex", {
		dom = "sex/SexStanding_1",
		sub = "sex/SexStanding_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_SPEEDMULT_MIN: 0.9,
		CONF_SPEEDMULT_MAX: 1.1,
		CONF_TIMEDSPEEDSWITCH_MIN: 5.0,
		CONF_TIMEDSPEEDSWITCH_MAX: 10.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(7, "plap"),
		],
	})
	addState("fast", {
		dom = "sex/SexStandingFast_1",
		sub = "sex/SexStandingFast_2",
	}, {
		CONF_BASESPEED: 1.5,
		CONF_SPEEDMULT_MIN: 0.8,
		CONF_SPEEDMULT_MAX: 1.1,
		CONF_TIMEDSPEEDSWITCH_MIN: 3.0,
		CONF_TIMEDSPEEDSWITCH_MAX: 10.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(7, "plap"),
		],
	})
	addState("inside", {
		dom = "sex/SexStandingInside_1",
		sub = "sex/SexStandingInside_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_SPEEDMULT_MIN: 0.8,
		CONF_SPEEDMULT_MAX: 1.1,
		CONF_TIMEDSPEEDSWITCH_MIN: 3.0,
		CONF_TIMEDSPEEDSWITCH_MAX: 10.0,
		CONF_ANIMEVENTS: [
		],
	})
	addState("cum", {
		dom = "sex/SexStandingCum_1",
		sub = "sex/SexStandingCum_2",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(7, "plap"),
			animEventOnFrame(10, "cumInsideSound"),
			animEventOnFrame(22, "cumInsideSound"),
			animEventOnFrame(30, "plap"),
			animEventOnFrame(35, "cumInsideSound"),
			animEventOnFrame(77, "plap"),
			animEventOnFrame(82, "cumInsideSound"),
		],
	})
	
	connectStates("tease", "inside", 0.5)
	connectStates("inside", "slow", 0.5)
	connectStates("tease", "slow", 0.5)
	connectStates("slow", "sex", 0.5)
	connectStates("sex", "fast", 0.5)
	
	connectStates("sex", "cum", 0.5, true)
	connectStates("fast", "cum", 0.5, true)
	connectStates("cum", "inside", 1.0, true, true)
	
	addAdditiveOneshot("bottomCum", {
		dom = "sex/SexStandingBottomCum_1",
		sub = "sex/SexStandingBottomCum_2",
	}, {
		dom = "sex/SexStandingIn_1",
		sub = "sex/SexStandingIn_2",
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
	
func onPlayState(_state:String):
	pass

func onOneShot(_oneshotID:String):
	if(_oneshotID == "bottomCum"):
		doOrgasmNoise("sub")
		#doSquirtVagina("sub", 20.0, 0.3, 10.0)
		#doSquirtVagina("sub")
		#await get_tree().create_timer(0.5).timeout
		#doSquirtVagina("sub", 0.1, 0.3, 2.0, 15.0)
	
