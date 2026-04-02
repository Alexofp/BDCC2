extends Node
class_name TimeManager

const SECONDS_DAY := 86400

var time:int = 0 # seconds since the 'today' has started
var day:int = 0 # how many days have passed

var timeFloat:float = 0.0
var syncTimeTimer:float = 0.0

func _physics_process(_delta: float) -> void:
	timeFloat += _delta
	if(timeFloat >= 1.0):
		var toAdd:int = int(timeFloat)
		time += toAdd
		timeFloat -= toAdd
	
	while(time >= SECONDS_DAY):
		time -= SECONDS_DAY
		if(Network.isServer()):
			onNewDay()

	# Sync the time every 10 seconds
	if(Network.isServerNotSingleplayer()):
		syncTimeTimer += _delta
		if(syncTimeTimer > 10.0):
			syncTimeTimer = 0.0
			syncTime()

func onNewDay():
	pass

func getTimeFull() -> int:
	return day*SECONDS_DAY + time

static func getDayAt(_fullTime:int) -> int:
	@warning_ignore("integer_division")
	return _fullTime / SECONDS_DAY

static func getSecondsSinceDayStart(_fullTime:int) -> int:
	return _fullTime % SECONDS_DAY

static func advanceFullTime(_am:int, _adv:int) -> int:
	return _am + _adv

func syncTime():
	if(!Network.isServerNotSingleplayer()):
		return
	Network.rpcClients(syncTime_RPC.bind(saveNetworkData()))

@rpc("authority", "call_remote", "reliable")
func syncTime_RPC(_networkData:PackedByteArray):
	var theBins := Bins.readUncompressed(_networkData)
	loadNetworkData(theBins)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.U32, time,
		Bins.U32, day,
		])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	time = _data.readU32()
	day = _data.readU32()
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		time = time,
		day = day,
	}

func loadData(_data:Dictionary):
	time = SAVE.loadVar(_data, "time", 0)
	day = SAVE.loadVar(_data, "day", 0)
