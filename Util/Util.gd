extends Object
class_name Util

static func delete_children(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

static func remove_all_signals(node: Node):
	var signals = node.get_signal_list()
	for cur_signal in signals:
		var conns = node.get_signal_connection_list(cur_signal.name)
		for cur_conn in conns:
			node.disconnect(cur_conn.signal, cur_conn.target)

static func remove_all_signals_with_target(node: Node, targetNode):
	var signals = node.get_signal_list()
	for cur_signal in signals:
		var conns = node.get_signal_connection_list(cur_signal.name)
		for cur_conn in conns:
			if(targetNode == cur_conn.target):
				node.disconnect(cur_conn.signal, cur_conn.target)

static func getAllMeshInstancesOfANode(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	
	var tocheck = [node]
	while(!tocheck.is_empty()):
		var thenode:Node = tocheck.pop_back()
		
		for n in thenode.get_children():
			if(n is MeshInstance3D):
				result.append(n)
			if(n.get_child_count() > 0):
				tocheck.append(n)
	
	return result

static func getFirstSkeleton3DOfANode(node: Node) -> Skeleton3D:
	var tocheck = [node]
	
	while(!tocheck.is_empty()):
		var thenode:Node = tocheck.pop_back()
		
		if(thenode is Skeleton3D):
			return thenode
		
		tocheck.append_array(thenode.get_children())
	
	return null

static func getScriptsInFolder(folder: String) -> Array[String]:
	return getResourcesFromFolder(folder, ["gd"])
	#var result = []
	#
	#var dir = DirAccess.open(folder)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if dir.current_is_dir():
				#pass
				##print("Found directory: " + file_name)
			#else:
				#if(file_name.get_extension() == "gd"):
					#var full_path = folder.path_join(file_name)
					#result.append(full_path)
			#file_name = dir.get_next()
	#else:
		#Log.Printerr("An error occurred when trying to access the path "+folder)
	#
	#return result

static func getScriptsInFolderSmart(folder: String, includeThisFolder = true, includeSubFolders = true, reqursive = true) -> Array:
	#return getFilesInFolderSmart(folder, "gd", includeThisFolder, includeSubFolders, reqursive)
	return getResourcesFromFolderSmart(folder, ["gd"], includeThisFolder, includeSubFolders, reqursive)

static func getFilesInFolderSmart(folder: String, extension:String, includeThisFolder = true, includeSubFolders = true, reqursive = true) -> Array:
	var result:Array = []
	
	var dir = DirAccess.open(folder)
	if dir:
		dir.include_navigational = false
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if(includeSubFolders):
					var full_path = folder.path_join(file_name)
					result.append_array(getScriptsInFolderSmart(full_path, true, reqursive))
				#print("Found directory: " + file_name)
			else:
				if(!includeThisFolder):
					file_name = dir.get_next()
					continue
				if(file_name.get_extension() == extension):
					var full_path = folder.path_join(file_name)
					result.append(full_path)
			file_name = dir.get_next()
	else:
		Log.Printerr("An error occurred when trying to access the path "+folder)
	
	return result

static func fix_resource_path(file:String) -> String:
	if file.ends_with(".remap"):
		file = file.trim_suffix(".remap")
	elif file.ends_with(".import"): #TODO: This might be breaking stuff but its required for sounds in exported builds
		file = file.trim_suffix(".import")
	return file

static func fix_resource_path_only_remap(file:String) -> String:
	if file.ends_with(".remap"):
		file = file.trim_suffix(".remap")
	return file

static func getFilesInFolderSmartFixPath(folder: String, ext: String, includeThisFolder = true, includeSubFolders = true, reqursive = true, getFullPath:bool = true) -> Array:
	var result:Array = []
	
	var dir = DirAccess.open(folder)
	if dir:
		dir.include_navigational = false
		dir.list_dir_begin()
		var file_name = fix_resource_path(dir.get_next())
		while file_name != "":
			if dir.current_is_dir():
				if(includeSubFolders):
					var full_path = folder.path_join(file_name)
					result.append_array(getFilesInFolderSmart(full_path, ext, true, reqursive))
				#print("Found directory: " + file_name)
			else:
				if(!includeThisFolder):
					file_name = fix_resource_path(dir.get_next())
					continue
				if(file_name.get_extension() == ext):
					if(getFullPath):
						var full_path = folder.path_join(file_name)
						result.append(full_path)
					else:
						result.append(file_name)
			file_name = fix_resource_path(dir.get_next())
	else:
		printerr("An error occurred when trying to access the path "+folder)
	
	return result

static func moveValueUp(theArray, theIndex):
	var thingie = theArray[theIndex]
	theArray.remove_at(theIndex)
	theIndex -= 1
	if(theIndex < 0):
		theIndex = 0
	theArray.insert(theIndex, thingie)

static func moveValueDown(theArray, theIndex):
	var thingie = theArray[theIndex]
	theArray.remove_at(theIndex)
	theIndex += 1
	if(theIndex > theArray.size()):
		theIndex = theArray.size()
	theArray.insert(theIndex, thingie)

# https://godotengine.org/qa/20058/elegant-way-to-create-string-from-array-items
static func join(arr: Array, separator: String = "") -> String:
	var output = ""
	for s in arr:
		output += str(s) + separator
	output = output.left( output.length() - separator.length() )
	return output

# TODO: maybe switch name sanitizing to allowlist rather than blocklist. Only allow ASCII letter, numbers, some extra characters
static func sanitizeCharacterName(_theName:String) -> String:
	var result:String = ""
	
	_theName = _theName.strip_escapes()
	
	for letter in _theName:
		if(letter in ["\n", "\r", "\t", "[", "]", "(", ")", "{", "}", "=", "$", "#", "@", "\\", "/", "<", ">"]):
			continue
		result += letter
	
	return result

static func sanitizeFileName(_theName:String) -> String:
	_theName = _theName.strip_escapes()
	_theName = _theName.validate_filename()
	return _theName
	

static func folderExists(path:String) -> bool:
	#var dir = DirAccess.open(path)
	#if(dir):
	#	return true
	if(DirAccess.dir_exists_absolute(path)):
		return true
	return false

static func createFolder(_path:String):
	DirAccess.make_dir_recursive_absolute(_path)

## Returned path is local to the folder. Technically faster than getResourcesFromFolder() but you need to join it with the folder yourself
static func getResourcesFromFolderLocalPath(_folder:String, _extentions:Array[String]) -> Array[String]:
	var result:Array[String] = []
	var resourceList := ResourceLoader.list_directory(_folder)
	for resourcePath in resourceList:
		var extension := resourcePath.get_extension()
		# For editor builds
		if (extension in _extentions):
			result.append(resourcePath)
	return result

static func getResourcesFromFolder(_folder:String, _extentions:Array[String]) -> Array[String]:
	var result:Array[String] = []
	var resourceList := ResourceLoader.list_directory(_folder)
	for resourcePath in resourceList:
		var extension := resourcePath.get_extension()
		# For editor builds
		if (extension in _extentions):
			result.append(_folder.path_join(resourcePath))
	return result

static func getResourcesFromFolderRecursiveLocalPath(_folder:String, _extentions:Array[String]) -> Array[String]:
	var result:Array[String] = []
	var resourceList := ResourceLoader.list_directory(_folder)
	for resourcePath in resourceList:
		if(resourcePath.ends_with("/")):
			var extraPaths := getResourcesFromFolderRecursiveLocalPath(_folder.path_join(resourcePath), _extentions)
			for extraPath in extraPaths:
				result.append(resourcePath.path_join(extraPath))
		else:
			var extension := resourcePath.get_extension()
			# For editor builds
			if (extension in _extentions):
				result.append(resourcePath)
	return result

static func getResourcesFromFolderRecursive(_folder:String, _extentions:Array[String]) -> Array[String]:
	var result:Array[String] = []
	var resourceList := ResourceLoader.list_directory(_folder)
	for resourcePath in resourceList:
		if(resourcePath.ends_with("/")):
			var extraPaths := getResourcesFromFolderRecursiveLocalPath(_folder.path_join(resourcePath), _extentions)
			for extraPath in extraPaths:
				result.append(_folder.path_join(resourcePath.path_join(extraPath)))
		else:
			var extension := resourcePath.get_extension()
			# For editor builds
			if (extension in _extentions):
				result.append(_folder.path_join(resourcePath))
	return result

static func getResourcesFromFolderSmart(_folder:String, _extentions:Array[String], includeThisFolder:bool = true, includeSubFolders:bool = true, reqursive:bool = true, fullPath:bool = true) -> Array[String]:
	var result:Array[String] = []
	var resourceList := ResourceLoader.list_directory(_folder)
	for resourcePath in resourceList:
		if(resourcePath.ends_with("/")):
			if(includeSubFolders):
				var extraPaths := getResourcesFromFolderSmart(_folder.path_join(resourcePath), _extentions, true, reqursive, reqursive, fullPath)
				for extraPath in extraPaths:
					result.append(extraPath if fullPath else resourcePath.path_join(extraPath))
		elif(includeThisFolder):
			var extension := resourcePath.get_extension()
			# For editor builds
			if (extension in _extentions):
				result.append(_folder.path_join(resourcePath) if fullPath else resourcePath)
	return result

# Input: 127.0.0.1:12345
# output: ["127.0.0.1", 12345]
# Input: 127.0.0.1
# output: ["127.0.0.1"]
# Input: 127.0.0.1:12345:6969
# output: ["127.0.0.1", 12345]
static func separateIPPort(address:String) -> Array:
	if address.contains(":"):
		var parts:Array = address.split(":")
		var host:String = parts[0]
		var port:int = (parts[1] as String).to_int()
		return [host, port]
	else:
		return [address]

## input splitOnFirst("Test.Meow.Woof", ".")
## output ["Test", "Meow.Woof"]
## Might either return a one element array or a 2 element array
static func splitOnFirst(theText: String, sep: String) -> Array[String]:
	if sep.is_empty():
		return [theText]

	var idx := theText.find(sep)
	if idx == -1:
		return [theText]

	var before := theText.substr(0, idx)
	var after := theText.substr(idx + sep.length(), theText.length() - (idx + sep.length()))
	return [before, after]

# Always return sa 2-element array
static func splitOnFirstOLD(text: String, separator: String) -> Array[String]:
	var stuff:PackedStringArray = text.split(separator)
	
	if(stuff.is_empty()):
		return ["", ""]
	if(stuff.size() <= 1):
		return [stuff[0], ""]
	
	var firstEntry:String = stuff[0]
	stuff.remove_at(0)
	
	return [firstEntry, join(stuff, separator)]

## Rounds a float number up to the specified amount of digits after the dot
## round(123.456, 1) returns 123.5
static func roundF(number: float, digitsAmount: int = 0) -> float:
	var mult:float = 1.0
	for _i in range(digitsAmount):
		mult *= 10.0
	
	return round(number*mult)/mult

static func setBit(mask: int, bit: int, on: bool) -> int:
	if bit < 0:
		push_error("set_bit: bit index must be >= 0")
		return mask
	var bitmask: int = 1 << bit
	if on:
		return mask | bitmask
	else:
		# & ~bitmask clears that bit
		return mask & ~bitmask

static func setBitOn(mask: int, bit: int) -> int:
	if bit < 0:
		push_error("set_bit: bit index must be >= 0")
		return mask
	var bitmask: int = 1 << bit
	return mask | bitmask

static func setBitOff(mask: int, bit: int) -> int:
	if bit < 0:
		push_error("set_bit: bit index must be >= 0")
		return mask
	var bitmask: int = 1 << bit
	return mask & ~bitmask

static func getBit(mask: int, bit: int) -> bool:
	if bit < 0:
		push_error("get_bit: bit index must be >= 0")
		return false
	return (mask & (1 << bit)) != 0

#static func countBits(mask: int) -> int:
	#var x: int = mask
	## Normalize negative values to their 64-bit two's-complement representation
	## so counting works predictably. Adjust mask width if needed.
	#if x < 0:
		#x = mask & 0xFFFFFFFFFFFFFFFF
	#var count: int = 0
	#while x != 0:
		#x &= x - 1
		#count += 1
	#return count
