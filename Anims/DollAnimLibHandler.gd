extends RefCounted
class_name DollAnimLibHandler

var animPlayer:AnimationPlayer
var toLoad:Array[String]
var added:Dictionary[String, DollAnimLib]
var addedAmmounts:Dictionary[String, int]

func setAnimPlayer(_animPlayer:AnimationPlayer):
	animPlayer = _animPlayer
	for theLib:DollAnimLib in GlobalRegistry.animLibsAlwaysAdd:
		addAnimLib(theLib.id)

#func processHandler(_dt:float):
#	pass

func getAnimationInfo(_name:String) -> Array:
	return GlobalRegistry.getDollLibAnimationInfo(_name)
	#var theSplit:Array[String] = Util.splitOnFirst(_name, "/")
	#if(theSplit.size() < 2):
	#	return []
	#if(!added.has(theSplit[0])):
	#	return []
	#var theLib:DollAnimLib = added[theSplit[0]]
	#if(!theLib.animToInfo.has(theSplit[1])):
	#	return []
	#return theLib.animToInfo[theSplit[1]]

#func addAnimLibIfNotAdded(_id:String):
#	if(added.has(_id)):
#		return
#	addAnimLib(_id)
	
func addAnimLib(_id:String):
	var theLib:DollAnimLib = GlobalRegistry.getAnimLib(_id)
	if(!theLib):
		return
	if(added.has(_id)):
		addedAmmounts[_id] += 1
		return
	if(animPlayer.has_animation_library(_id)):
		Log.Printerr("SOMETHING WENT WRONG, ANIM PLAYER ALREADY HAS '"+_id+"' ANIM LIBRARY")
		return
	if(theLib.cachedLib):
		animPlayer.add_animation_library(_id, theLib.cachedLib)
		added[_id] = theLib
		addedAmmounts[_id] = 1
		return
	if(toLoad.has(_id)):
		# Already loading it
		return
	added[_id] = theLib
	addedAmmounts[_id] = 1
	toLoad.append(_id)
	var theLibResource:AnimationLibrary = await GlobalRegistry.loadThreaded(theLib.libPath)
	if(!theLibResource):
		toLoad.erase(_id)
		return
	#await animPlayer.get_tree().create_timer(3.0).timeout
	if(!toLoad.has(_id)): # We lost the need to have this lib
		return
	toLoad.erase(_id)
	animPlayer.add_animation_library(_id, theLibResource)

func removeAnimLib(_id:String):
	if(addedAmmounts.has(_id)):
		addedAmmounts[_id] -= 1
		if(addedAmmounts[_id] > 0):
			return
		addedAmmounts.erase(_id)
	
	toLoad.erase(_id)
	if(added.has(_id)):
		var theAnimLib:DollAnimLib = added[_id]
		if(theAnimLib.alwaysAdd):
			Log.Printerr("Trying to remove an anim lib that is supposed to always be added: "+(_id))
			return
		added.erase(_id)
		animPlayer.remove_animation_library(_id)

#func loadThreaded(_path:String) -> Resource:
#	if(ResourceLoader.has_cached(_path)):
#		return ResourceLoader.load(_path)
#	
#	var err:= ResourceLoader.load_threaded_request(_path)
#	if(err != OK):
#		printerr("ERROR! "+error_string(err))
#		return null
#	
#	var loadStatus := ResourceLoader.load_threaded_get_status(_path)
#	while(loadStatus == ResourceLoader.THREAD_LOAD_IN_PROGRESS):
#		await animPlayer.get_tree().process_frame
#		loadStatus = ResourceLoader.load_threaded_get_status(_path)
#	
#	if(loadStatus != ResourceLoader.THREAD_LOAD_LOADED):
#		printerr("FAILED TO LOAD! loadStatus="+str(loadStatus))
#		return null
#	
#	return ResourceLoader.load_threaded_get(_path)
