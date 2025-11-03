extends RefCounted
class_name SimpleGameTextParser

class Result:
	var text:String
	var hadError:bool = false
	var errorText:String = ""

func getSimpleGameTextParserText(_id:String, _command:String, _arg:String) -> SGTPResult:
	return SGTPResult.make("")

func applyObjReplacers(_inputStr:String, replacers:Dictionary[String, String] = {}) -> String:
	var errors:Array[String] = []
	var hadError:bool = false
	var finalText:String = ""
	
	var thePartsResult := stringToParts(_inputStr)
	if(thePartsResult[1]):
		hadError = true
		errors.append(thePartsResult[2])
	
	var theParts:Array = thePartsResult[0]
	
	for theEntry in theParts:
		var entryType:int = theEntry[0]
		var entryText:String = theEntry[1]
	
		if(entryType == 0):
			finalText += entryText
		elif(entryType == 1):
			var theArgSplit := Util.splitOnFirst(entryText, " ")
			var theCommandEntry:String = theArgSplit[0]
			var theArg:String = theArgSplit[1] if theArgSplit.size() > 1 else ""
			
			var theCommandSplit := Util.splitOnFirst(theCommandEntry, ".")
			
			var theObjKey:String = ""
			var theCommand:String = ""
			if(theCommandSplit.size() == 1):
				#theCommand = theCommandSplit[0]
				finalText += "{"+entryText+"}"
			else:
				theObjKey = theCommandSplit[0]
				theCommand = theCommandSplit[1]
			
			if(replacers.has(theObjKey)):
				theObjKey = replacers[theObjKey]
			
			finalText += "{"+theObjKey+"."+theCommand+" "+theArg+"}"
		else:
			hadError = true
			errors.append("UNKNOWN ERROR.")
	
	#var theFinalResult:Result = Result.new()
	#theFinalResult.text = finalText
	#theFinalResult.hadError = hadError
	#theFinalResult.errorText = Util.join(errors, "\n")
	if(hadError):
		Log.Printerr(Util.join(errors, "\n"))
	return finalText

func parseString(_inputStr:String, _callable:Callable, replacers:Dictionary[String, String] = {}, textOverrides:Dictionary[String, String] = {}) -> Result:
	var errors:Array[String] = []
	var hadError:bool = false
	var finalText:String = ""
	
	var thePartsResult := stringToParts(_inputStr)
	if(thePartsResult[1]):
		hadError = true
		errors.append(thePartsResult[2])
	
	var theParts:Array = thePartsResult[0]
	
	for theEntry in theParts:
		var entryType:int = theEntry[0]
		var entryText:String = theEntry[1]
	
		if(entryType == 0):
			finalText += entryText
		elif(entryType == 1):
			var theArgSplit := Util.splitOnFirst(entryText, " ")
			var theCommandEntry:String = theArgSplit[0]
			var theArg:String = theArgSplit[1] if theArgSplit.size() > 1 else ""
			
			var theCommandSplit := Util.splitOnFirst(theCommandEntry, ".")
			
			var theObjKey:String = ""
			var theCommand:String = ""
			if(theCommandSplit.size() == 1):
				theCommand = theCommandSplit[0]
			else:
				theObjKey = theCommandSplit[0]
				theCommand = theCommandSplit[1]
			
			if(replacers.has(theObjKey)):
				theObjKey = replacers[theObjKey]
			
			if(theObjKey.is_empty() && textOverrides.has(theCommand)):
				# Should there be a first letter cap logic here?
				finalText += textOverrides[theCommand]
			else:
				var shouldCapFirstLetter:bool = false
				if(!theCommand.is_empty() && theCommand[0].to_lower() != theCommand[0]):
					theCommand[0] = theCommand[0].to_lower()
					shouldCapFirstLetter = true
				
				var theResult:SGTPResult = _callable.call(theObjKey, theCommand, theArg)
				if(!theResult):
					errors.append("RETURNED NULL")
					finalText += "(NULL:"+entryText+")"
				elif(!theResult.error.is_empty()):
					errors.append(theResult.error)
					finalText += "(ERROR:"+entryText+":"+theResult.error+")"
				else:
					var theText:String = theResult.text
					if(shouldCapFirstLetter && !theText.is_empty()):
						theText[0] = theText[0].to_upper()
					finalText += theText
		else:
			hadError = true
			errors.append("UNKNOWN ERROR.")
	
	var theFinalResult:Result = Result.new()
	theFinalResult.text = finalText
	theFinalResult.hadError = hadError
	theFinalResult.errorText = Util.join(errors, "\n")
	if(hadError):
		Log.Printerr(theFinalResult.errorText)
	return theFinalResult

func stringToParts(_inputStr:String) -> Array:
	var result:Array = []
	var hadErrors:bool = false
	var errors:Array[String] = []
	var _i:int = 0
	
	var strLen:int = _inputStr.length()
	
	var theBuffer:String = ""
	var theState:int = 0 # 0 = searching for {, 1 = searching for }
	while(_i <= strLen):
		var theCh:String = _inputStr[_i] if _i < strLen else ""
		
		if(theState == 0):
			if(theCh == ""): # eof
				if(!theBuffer.is_empty()):
					result.append([0, theBuffer])
					theBuffer = ""
			elif(theCh == "\\" && peekSafe(_inputStr, _i+1) in ["{","}"]):
				theBuffer += peekSafe(_inputStr, _i+1)
				_i += 1
			elif(theCh == "{"):
				if(!theBuffer.is_empty()):
					result.append([0, theBuffer])
					theBuffer = ""
				theState = 1
			elif(theCh == "}"):
				hadErrors = true
				errors.append("UNEXPECTED '}'. DID YOU FORGET TO ESCAPE IT?")
			else:
				theBuffer += theCh
		
		
		elif(theState == 1):
			if(theCh == ""): # eof
				hadErrors = true
				errors.append("UNEXPECTED END OF STRING. FORGOT '}'?")
				# ignoring the buffer
				
			if(theCh == "\\" && peekSafe(_inputStr, _i+1) in ["}","{"]):
				theBuffer += peekSafe(_inputStr, _i+1)
				_i += 1
			elif(theCh == "}"):
				result.append([1, theBuffer])
				theBuffer = ""
				theState = 0
			elif(theCh == "{"):
				hadErrors = true
				errors.append("UNEXPECTED '{'. DID YOU FORGET TO ESCAPE IT?")
			else:
				theBuffer += theCh
		
		_i += 1
	
	return [result, hadErrors, Util.join(errors, " ")]

func peekSafe(_str:String, _i:int) -> String:
	if(_i < 0 || _i >= _str.length()):
		return ""
	return _str[_i]
