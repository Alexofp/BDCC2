extends RefCounted
class_name SexSoundBank

var sounds:Array = [
]

func addFullMoanSetup(voiceID:String, voiceActor:String, basePath:String):
	for mouthState in SexSoundMouth.getAll():
		var finalPath:String = basePath
		finalPath = finalPath.path_join("Orgasm/"+SexSoundMouth.toFolderName(mouthState))
		var theEntries:Array = getEntriesFromFolder(finalPath)
		#print(theEntries)
		
		if(!theEntries.is_empty()):
			sounds.append({
				type = SexSoundType.Orgasm,
				voice = voiceID,
				
				voiceActor = voiceActor,
				
				mouth = mouthState,
				intensity = SexSoundIntensity.Low,
				speed = SexSoundSpeed.Slow,
				
				sounds = theEntries,
			})
	
	if(true):
		var finalPath:String = basePath
		finalPath = finalPath.path_join("Orgasm/Panting/")
		#print(finalPath)
		var theEntries:Array = getEntriesFromFolder(finalPath)
		#print(theEntries)
		
		if(!theEntries.is_empty()):
			sounds.append({
				type = SexSoundType.OrgasmPanting,
				voice = voiceID,
				
				voiceActor = voiceActor,
				
				mouth = SexSoundMouth.Opened,
				intensity = SexSoundIntensity.Low,
				speed = SexSoundSpeed.Slow,
				
				sounds = theEntries,
			})
	
	for mouthState in SexSoundMouth.getAll():
		for intensity in SexSoundIntensity.getAll():
			for speed in SexSoundSpeed.getAll():
				
				var finalPath:String = basePath
				
				finalPath = finalPath.path_join("Moans/"+SexSoundMouth.toFolderName(mouthState)+SexSoundIntensity.toFolderName(intensity)+SexSoundSpeed.toFolderName(speed))
				
				var theEntries:Array = getEntriesFromFolder(finalPath)
				if(theEntries.is_empty()):
					continue
				
				sounds.append({
					type = SexSoundType.Moan,
					voice = voiceID,
					
					voiceActor = voiceActor,
					
					mouth = mouthState,
					intensity = intensity,
					speed = speed,
					
					sounds = theEntries,
				})

func getEntriesFromFolder(folder:String, ext:String="ogg") -> Array:
	if(!Util.folderExists(folder)):
		return []
	var theFiles:Array = Util.getFilesInFolderSmartFixPath(folder, ext, true, false, false)
	
	var result:Array = []
	
	for fileName in theFiles:
		result.append({
			path = fileName,
			trimBack = 0.0,
		})
	
	return result
