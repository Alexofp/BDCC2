extends Control

func _ready() -> void:
	#var someStream := StreamPeerBuffer.new()
	#print(someStream.get_size())
	
	#if(true):
	#	return
	var bins:Bins = Bins.saveStart([
		Bins.I64, 123,
		Bins.Double, 420.69,
		Bins.Str, "Hello world! Hello world! Hello world! Hello world! Hello world! Hello world! Hello world! Hello world! ",
		Bins.Var, ["HUH?", 543],
		Bins.BINS, writeTest(),
	])
	#bins.saveVar(["HUH? LOL?", 543])
	#bins.append(writeTest())
	bins.endSave()
	
	print("ORIG: "+str(bins.debugStr()))
	
	#var theDataSize := bins.getBytesSize()
	var theData := bins.getBytesCompressedSimple() #bins.getBytesCompressed(FileAccess.COMPRESSION_DEFLATE)#
	print("COMP: "+str(theData))
	print("COMP SIZE: "+str(theData.size()))
	
	var newBins:Bins = Bins.readCompressedSimple(theData)#Bins.readCompressed(theData, theDataSize, FileAccess.COMPRESSION_DEFLATE)
	newBins.loadStart()
	print("LOAD: "+str(newBins.debugStr()))
	print("I64: "+str(newBins.readI64()))
	print("Double: "+str(newBins.readDouble()))
	print("String: "+str(newBins.readStr()))
	print("Var: "+str(newBins.readVar()))
	readTest(newBins.readBins())
	newBins.endLoad()
	
	#print("TEST: "+str( newBins.bytes.size() )+"  "+str( var_to_bytes(newBins.bytes).size() ))
	#var testP := PackedByteArray()
	#print("TEST: "+str( testP.size() )+"  "+str( var_to_bytes(testP).size() ))
	
func writeTest() -> Bins:
	var newBins := Bins.saveStart()
	newBins.save([
		Bins.I64, 123456,
		Bins.StrShort, "MEOW meow!",
	])
	newBins.endSave()
	return newBins

func readTest(_data:Bins):
	print("BEGAN TEST READ!")
	_data.loadStart()
	print("TEST I64: "+str(_data.readI64()))
	print("TEST STR: "+str(_data.readStrShort()))
	_data.endLoad()
