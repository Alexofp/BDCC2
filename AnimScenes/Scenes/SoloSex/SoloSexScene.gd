extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot

func _init() -> void:
	id = "solo_sex"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	
	addAnimLibrary("soloSex", "res://Anims/Raw/SoloSex.glb")
	
	addState("start", {
		dom = "soloSex/Start_1",
	}, {
		CONF_BASESPEED: 1.0,
	})
	addState("rubTease", {
		dom = "soloSex/RubTease_1",
	}, {
		CONF_BASESPEED: 1.0,
	})
	addState("rubSlow", {
		dom = "soloSex/RubSlow_1",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(26, "moan"),
		],
		CONF_HIDETAGS: {
			dom = [SexHideTag.ArmRestraint],
		},
	})
	addState("rub", {
		dom = "soloSex/Rub_1",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(17, "moan"),
		],
		CONF_HIDETAGS: {
			dom = [SexHideTag.ArmRestraint],
		},
	})
	addState("rubFast", {
		dom = "soloSex/RubFast_1",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(13, "moan"),
		],
		CONF_HIDETAGS: {
			dom = [SexHideTag.ArmRestraint],
		},
	})
	addState("rubOrgasm", {
		dom = "soloSex/RubOrgasm_1",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(1, "orgasm"),
			animEventOnFrame(10, "squirt"),
			animEventOnFrame(33, "squirt"),
			animEventOnFrame(55, "squirt"),
			animEventOnFrame(88, "squirt"),
			animEventOnFrame(111, "squirt"),
		],
		CONF_HIDETAGS: {
			dom = [SexHideTag.ArmRestraint],
		},
	})
	
	addState("strokeTease", {
		dom = "soloSex/StrokeTease_1",
	}, {
		CONF_BASESPEED: 1.0,
	})
	addState("strokeSlow", {
		dom = "soloSex/StrokeSlow_1",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(26, "moanStroke"),
		],
		CONF_HIDETAGS: {
			dom = [SexHideTag.ArmRestraint],
		},
	})
	addState("stroke", {
		dom = "soloSex/Stroke_1",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(17, "moanStroke"),
		],
		CONF_HIDETAGS: {
			dom = [SexHideTag.ArmRestraint],
		},
	})
	addState("strokeFast", {
		dom = "soloSex/StrokeFast_1",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(13, "moanStroke"),
		],
		CONF_HIDETAGS: {
			dom = [SexHideTag.ArmRestraint],
		},
	})
	addState("strokeOrgasm", {
		dom = "soloSex/StrokeOrgasm_1",
	}, {
		CONF_BASESPEED: 1.0,
		CONF_ANIMEVENTS: [
			animEventOnFrame(1, "shootcum"),
			animEventOnFrame(7, "orgasm"),
			animEventOnFrame(33, "shootcum"),
			animEventOnFrame(55, "shootcum"),
			animEventOnFrame(88, "shootcum"),
		],
		CONF_HIDETAGS: {
			dom = [SexHideTag.ArmRestraint],
		},
	})
	
	addAdd3Layer("penisGirth", {
		dom = "soloSex/StrokeHandBig_1",
	}, {
		dom = "soloSex/StrokeHandSmall_1",
	}, {
		dom = "soloSex/StrokeHandNormal_1",
	})
	
	setStartState("start")
	connectStates("start", "rubTease", 0.6)
	connectStates("rubTease", "rubSlow", 0.6)
	connectStates("rubSlow", "rub", 0.7)
	connectStates("rub", "rubFast", 0.5)
	connectStates("rubFast", "rubTease", 0.8, true)
	connectStates("rub", "rubTease", 0.8, true)
	
	connectStates("rubSlow", "rubOrgasm", 0.3)
	connectStates("rub", "rubOrgasm", 0.3)
	connectStates("rubFast", "rubOrgasm", 0.3)
	
	connectStates("rubOrgasm", "rubTease", 1.5, true, true)
	
	
	connectStates("start", "strokeTease", 0.6)
	connectStates("strokeTease", "strokeSlow", 0.6)
	connectStates("strokeSlow", "stroke", 0.7)
	connectStates("stroke", "strokeFast", 0.5)
	connectStates("strokeFast", "strokeTease", 0.8, true)
	connectStates("stroke", "strokeTease", 0.8, true)
	
	connectStates("strokeSlow", "strokeOrgasm", 0.3)
	connectStates("stroke", "strokeOrgasm", 0.3)
	connectStates("strokeFast", "strokeOrgasm", 0.3)
	connectStates("strokeOrgasm", "strokeTease", 1.5, true, true)
	
	updateAllAnimTrees()

func onAnimationEvent(_eventID:String):
	if(_eventID == "orgasm"):
		doOrgasmNoise("dom")
	if(_eventID == "squirt"):
		doSquirtVagina("dom")
		doSquirtVagina("dom", 0.1, 0.3, 2.0, 15.0)
	if(_eventID == "moan"):
		doSquirtVagina("dom", RNG.randfRange(-0.3, 0.3), 0.2, 1.0, 45.0)
		if(getState() in ["rubFast", "rubOrgasm"]):
			doMoan("dom", SexSoundSpeed.Medium, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 1)
		elif(getState() == "rub"):
			doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 2)
		elif(getState() == "rubSlow"):
			doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(25) else SexSoundMouth.Closed, 2)
	
	if(_eventID == "moanStroke"):
		if(getState() in ["strokeFast", "strokeOrgasm"]):
			doMoan("dom", SexSoundSpeed.Medium, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 2)
		elif(getState() == "stroke"):
			doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 3)
		elif(getState() == "strokeSlow"):
			doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(25) else SexSoundMouth.Closed, 3)
	
	if(_eventID == "shootcum"):
		doCumOutsideEffect("dom")
	
func onPlayState(_state:String, _args:Dictionary):
	super.onPlayState(_state, _args)
	if(_state in ["stroke", "strokeTease", "strokeFast", "strokeSlow", "strokeOrgasm"]):
		alignPenisToPenisGuides("dom")
	else:
		alignPenisReset("dom")

func updateAnimWhenDollsChange():
	if(getState() in ["stroke", "strokeTease", "strokeFast", "strokeSlow", "strokeOrgasm"]):
		var theGirth:float = (getDollPenisGirth("dom")-1.0)
		theGirth *= 2.0
		setAdd3Value("penisGirth", clamp(theGirth, -1.0, 1.0))
	else:
		setAdd3Value("penisGirth", 0.0)
