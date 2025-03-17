extends Node

var resourcePathToCallablesArray:Dictionary[String, Array] = {}

const MaxInFlight := 1
var inFlight:Array[String] = []

var throttling:float = 0.0
const RequestThrottleTime = 0.1
const ArtificialThrottleTime = 0.0

#func loadAsync(thePath:String) -> Resource:
	#var result:Array = []
	#loadCallback(thePath, func(theResource):
		#result.append(theResource)
		#)

func loadCallback(thePath:String, theCallable:Callable):
	if(ResourceLoader.has_cached(thePath)):
		#print("HAS CACHED")
		theCallable.call(load(thePath))
		return
	if(ResourceLoader.load_threaded_get_status(thePath) == ResourceLoader.THREAD_LOAD_LOADED):
		#print("HAS CACHEDDDDDDDDD")
		theCallable.call(ResourceLoader.load_threaded_get(thePath))
		return
	if(!resourcePathToCallablesArray.has(thePath)):
		resourcePathToCallablesArray[thePath] = []
	
	resourcePathToCallablesArray[thePath].append(theCallable)
	
	if(!inFlight.has(thePath) && (inFlight.size() < MaxInFlight)):
		var err:= ResourceLoader.load_threaded_request(thePath)
		if(err != OK):
			theCallable.call(null)
			return
		inFlight.append(thePath)
		
		if(throttling < ArtificialThrottleTime):
			throttling = ArtificialThrottleTime

func _process(_delta: float) -> void:
	if(throttling > 0.0):
		throttling -= _delta
		return
	if(!inFlight.is_empty()):
		for inFlightPath in inFlight.duplicate():
			if(ResourceLoader.load_threaded_get_status(inFlightPath) != ResourceLoader.THREAD_LOAD_IN_PROGRESS):
				var theResource:Resource = ResourceLoader.load_threaded_get(inFlightPath)
				var allCallables:Array = resourcePathToCallablesArray[inFlightPath]
				
				for callable in allCallables:
					if(callable):
						callable.call(theResource)
				inFlight.erase(inFlightPath)
				resourcePathToCallablesArray.erase(inFlightPath)
				
				if(throttling < RequestThrottleTime):
					throttling = RequestThrottleTime
	
	if(inFlight.size() < MaxInFlight && !resourcePathToCallablesArray.is_empty()):
		tryStartExtraLoad()

func tryStartExtraLoad():
	for thePath in resourcePathToCallablesArray:
		if(inFlight.has(thePath)):
			continue
		var err:= ResourceLoader.load_threaded_request(thePath)
		if(err != OK):
			for theCallable in resourcePathToCallablesArray[thePath]:
				theCallable.call(null)
			return
		inFlight.append(thePath)
