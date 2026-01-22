extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot

func _init() -> void:
	id = "AgainstWallSolo"

func setupScene() -> void:
	addSeat("dom", sit_spot)
	
	addAnimLibrary("soloSex", "res://Anims/Raw/AgainstWallSolo.glb")
	
	addState("backLegUp", {
		dom = "soloSex/BackLegUp_1",
	})
	addState("stripSearch", {
		dom = "soloSex/StripSearch_1",
	})
	
	setStartState("backLegUp")
	connectStates("backLegUp", "stripSearch", 0.6)
	
#func onAnimationEvent(_eventID:String):
	#if(_eventID == "orgasm"):
		#doOrgasmNoise("dom")
	#if(_eventID == "squirt"):
		#doSquirtVagina("dom")
		#doSquirtVagina("dom", 0.1, 0.3, 2.0, 15.0)
	#if(_eventID == "moan"):
		#doSquirtVagina("dom", RNG.randfRange(-0.3, 0.3), 0.2, 1.0, 45.0)
		#if(getState() in ["rubFast", "rubOrgasm"]):
			#doMoan("dom", SexSoundSpeed.Medium, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 1)
		#elif(getState() == "rub"):
			#doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 2)
		#elif(getState() == "rubSlow"):
			#doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(25) else SexSoundMouth.Closed, 2)
	#
	#if(_eventID == "moanStroke"):
		#if(getState() in ["strokeFast", "strokeOrgasm"]):
			#doMoan("dom", SexSoundSpeed.Medium, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 2)
		#elif(getState() == "stroke"):
			#doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(95) else SexSoundMouth.Closed, 3)
		#elif(getState() == "strokeSlow"):
			#doMoan("dom", SexSoundSpeed.Slow, SexSoundMouth.Opened if RNG.chance(25) else SexSoundMouth.Closed, 3)
	#
	#if(_eventID == "shootcum"):
		#doCumOutsideEffect("dom")
	#
#func onPlayState(_state:String, _args:Dictionary):
	#super.onPlayState(_state, _args)
	#if(_state in ["stroke", "strokeTease", "strokeFast", "strokeSlow", "strokeOrgasm"]):
		#alignPenisToPenisGuides("dom")
	#else:
		#alignPenisReset("dom")
#
#func updateAnimWhenDollsChange():
	#if(getState() in ["stroke", "strokeTease", "strokeFast", "strokeSlow", "strokeOrgasm"]):
		#var theGirth:float = (getDollPenisGirth("dom")-1.0)
		#theGirth *= 2.0
		#setAdd3Value("penisGirth", clamp(theGirth, -1.0, 1.0))
	#else:
		#setAdd3Value("penisGirth", 0.0)
