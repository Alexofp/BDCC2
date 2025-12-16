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
	
	setStartState("start")
	connectStates("start", "rubTease", 0.6)
	connectStates("rubTease", "rubSlow", 0.6)
	connectStates("rubSlow", "rub", 0.7)
	connectStates("rub", "rubFast", 0.5)
	
	connectStates("rubSlow", "rubOrgasm", 0.3)
	connectStates("rub", "rubOrgasm", 0.3)
	connectStates("rubFast", "rubOrgasm", 0.3)
	
	
	connectStates("rubOrgasm", "rubTease", 1.5, true, true)
	
	
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
