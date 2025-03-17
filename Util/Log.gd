extends Object
class_name Log

static func error(text: String):
	var thePrefix:String = getDebugPrefix()
	printerr(thePrefix+text)
	if(FullscreenChat):
		FullscreenChat.addErrorMessage(thePrefix+text)
	#Console.printLine("[color=red]"+text+"[/color]")

static func Printerr(text: String):
	error(text)

static func warning(text: String):
	var thePrefix:String = getDebugPrefix()
	print(thePrefix+text)
	#Console.printLine("[color=yellow]"+text+"[/color]")

static func Print(text: String):
	var thePrefix:String = getDebugPrefix()
	print(thePrefix+text)
	if(FullscreenChat):
		FullscreenChat.addMessage(thePrefix+text)
	#Console.printLine(text)

static func getDebugPrefix() -> String:
	var prefix:String = ""
	if(Network && Network.isMultiplayer() && Network.isServer()):
		prefix = "[Server] "
	if(Network && Network.isMultiplayer() && Network.isClient()):
		var localPlayerInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
		prefix = "[Client:"+(localPlayerInfo.nickname if localPlayerInfo else "NOT_SYNCED_YET")+str(Network.getMultiplayerID()).substr(0, 4)+"] "
	return prefix
