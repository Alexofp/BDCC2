extends RefCounted
class_name BackgroundLoadRequest

const ERROR_NOERROR = 0
const ERROR_FAILED = 1
const ERROR_EMPTY_PATH = 2

var loadPath:String = ""
var result
var errorStatus:int = ERROR_NOERROR

signal requestFinished

func doLoad(_path:String, _tryAgainCount:int = 0):
	loadPath = _path
	await ThreadedResourceLoader.get_tree().process_frame
	if(loadPath == ""):
		errorStatus = ERROR_EMPTY_PATH
		result = "Trying to load an empty path"
		requestFinished.emit()
		return
	
	if(ResourceLoader.has_cached(loadPath)):
		result = ResourceLoader.load(loadPath)
		requestFinished.emit()
		return

	var err:= ResourceLoader.load_threaded_request(loadPath)
	if(err != OK):
		if(_tryAgainCount > 0):
			doLoad(loadPath, _tryAgainCount-1)
			return
		errorStatus = ERROR_FAILED
		requestFinished.emit()
		return
	
	var loadStatus := ResourceLoader.load_threaded_get_status(loadPath)
	while(loadStatus == ResourceLoader.THREAD_LOAD_IN_PROGRESS):
		await ThreadedResourceLoader.get_tree().process_frame
		loadStatus = ResourceLoader.load_threaded_get_status(loadPath)
	
	if(loadStatus != ResourceLoader.THREAD_LOAD_LOADED):
		if(_tryAgainCount > 0):
			doLoad(loadPath, _tryAgainCount-1)
			return
		errorStatus = ERROR_FAILED
		requestFinished.emit()
		return
	
	result = ResourceLoader.load_threaded_get(loadPath)
	if(!result && _tryAgainCount > 0):
		doLoad(loadPath, _tryAgainCount-1)
		return
	requestFinished.emit()
	

func isError() -> bool:
	return errorStatus != ERROR_NOERROR
	
func getError() -> int:
	return errorStatus
	
func getErrorString() -> String:
	if(errorStatus == ERROR_NOERROR):
		return ""
	if(errorStatus == ERROR_EMPTY_PATH):
		return "Tried to load an empty path"
	return "Failed to load"

func getResult():
	return result
