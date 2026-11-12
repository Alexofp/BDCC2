extends AnimSceneBase

@onready var sit_spot: PoseSpot = %SitSpot
@onready var sit_spot_2: PoseSpot = %SitSpot2
@onready var stand_spot: Marker3D = %StandSpot
@onready var prop_spot: PropSpot = %PropSpot

func _init() -> void:
	id = "stocksSex"

	propAnimLibs = {
		"stocks": ["StocksSolo_Stocks"],
	}
	animLibs = ["StocksSex_Doll"]

func setupScene() -> void:
	addSeat("dom", sit_spot)
	addSeat("sub", sit_spot_2)
	addPropSpot("stocks", prop_spot)
	
	addState("tease", {
		dom = "StocksSex_Doll/Tease_1",
		sub = "StocksSex_Doll/Tease_2",
		stocks = "StocksSolo_Stocks/Stocks_Normal",
	}).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("slow", {
		dom = "StocksSex_Doll/Slow_1",
		sub = "StocksSex_Doll/Slow_2",
		stocks = "StocksSolo_Stocks/Stocks_Normal",
	}).setSpeedAutoSwitch(0.9, 1.1, 5.0, 10.0).setAnimEvents([
		animEventOnFrame(17, "plap"),
	]).setHideTags({
		dom = [SexHideTag.ArmRestraint],
		sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("sex", {
		dom = "StocksSex_Doll/Sex_1",
		sub = "StocksSex_Doll/Sex_2",
		stocks = "StocksSolo_Stocks/Stocks_Normal",
	}).setSpeedAutoSwitch(0.9, 1.1, 5.0, 10.0).setAnimEvents([
		animEventOnFrame(9, "plap"),
	]).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("fast", {
		dom = "StocksSex_Doll/Fast_1",
		sub = "StocksSex_Doll/Fast_2",
		stocks = "StocksSolo_Stocks/Stocks_Normal",
	}).setSpeedAutoSwitch(0.8, 1.1, 3.0, 10.0).setAnimEvents([
		animEventOnFrame(7, "plap"),
	]).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("inside", {
		dom = "StocksSex_Doll/Inside_1",
		sub = "StocksSex_Doll/Inside_2",
		stocks = "StocksSolo_Stocks/Stocks_Normal",
	}).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		sub = TAIL_OUT_OF_THE_WAY_FLAGS,
	})
	addState("cum", {
		dom = "StocksSex_Doll/Cum_1",
		sub = "StocksSex_Doll/Cum_2",
		stocks = "StocksSolo_Stocks/Stocks_Normal",
	}).setAnimEvents([
			animEventOnFrame(6, "plap"),
			animEventOnFrame(8, "cumInsideSound"),
			animEventOnFrame(22, "cumInsideSound"),
			animEventOnFrame(30, "plap"),
			animEventOnFrame(35, "cumInsideSound"),
			animEventOnFrame(74, "plap"),
			animEventOnFrame(70, "cumInsideSound"),
	]).setHideTags({
			dom = [SexHideTag.ArmRestraint],
			sub = [SexHideTag.ArmRestraint],
	}).setFlags({
		sub = TAIL_OUT_OF_THE_WAY_FLAGS,
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
		dom = "StocksSex_Doll/BottomCum_1",
		sub = "StocksSex_Doll/BottomCum_2",
		stocks = "StocksSolo_Stocks/Stocks_Normal",
	}, {
		dom = "StocksSex_Doll/BottomCumBase_1",
		sub = "StocksSex_Doll/BottomCumBase_2",
		stocks = "StocksSolo_Stocks/Stocks_Normal",
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
