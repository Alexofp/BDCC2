extends RefCounted
class_name Bins # Binary Saver
# Heavily inspired by https://github.com/vysker/bytekruncher with an attempt to make it more perfomant

const DO_CHECKSUMS = true
const DO_SLOW_CHECKSUMS = false

#var bytes: PackedByteArray = PackedByteArray()
var bytes: StreamPeerBuffer = StreamPeerBuffer.new()
var openCounter:int = 0

# In order to add new type
#1. Add new enum entry
#2. Add new section into the getSizeOf() function that tells how many bytes it uses
#3. Add new section into the save() function to write the bytes
#4. Add new read...() function to read bytes into the right value

enum { # The most-used types should go first
	I64,
	I32,
	Double,
	Str, #String is taken by the engine
	StrShort,
	Bool,
	Float,
	ByteArray, #PackedByteArray
	BINS, #Bins
	Var, #Variant
	I8,
	Ignore,
}

func getSizeOf(_ar:Array) -> int:
	var pointer:int = 0
	for _ii in range(int(_ar.size()/2.0)):
		var _indx:int = _ii * 2
		var _type:int = _ar[_indx]
		#var _value:Variant = _ar[_indx+1]
		
		if(_type == I64):
			pointer += 8
		elif(_type == I32):
			pointer += 4
		elif(_type == Double):
			pointer += 8
		elif(_type == Str):
			pointer += 4 + _ar[_indx+1].to_utf8_buffer().size()
		elif(_type == StrShort):
			pointer += 2 + _ar[_indx+1].to_utf8_buffer().size()
		elif(_type == Bool):
			pointer += 1
		elif(_type == Float):
			pointer += 4
		elif(_type == ByteArray):
			pointer += 4 + _ar[_indx+1].size()
		elif(_type == BINS):
			pointer += 4 + _ar[_indx+1].bytes.get_size()
		elif(_type == Var):
			pointer += var_to_bytes(_ar[_indx+1]).size() + 4
		elif(_type == I8):
			pointer += 1
		elif(_type == Ignore):
			pointer += 0
			
		else:
			assert(false, "IMPLEMENT ME: TYPE: "+str(_type)+" VALUE: "+str(_ar[_indx+1]))
		
	return pointer

func save(_ar:Array, _addSaveMarker:bool = false):
	var arSize:int = _ar.size()
	if(arSize % 2 == 1):
		assert(false, "LAST VALUE IS MISSING")
	var cSize:int = bytes.get_size()
	var toReserve:= getSizeOf(_ar)
	if(_addSaveMarker):
		toReserve += 1
	
	var expectedFinalSize:int = cSize + toReserve
	
	bytes.resize(cSize + toReserve)
	
	if(_addSaveMarker):
		bytes.put_8(123)
	
	for _ii in range(int(arSize/2.0)):
		var _indx:int = _ii * 2
		var _type:int = _ar[_indx]
		var _value:Variant = _ar[_indx+1]
		
		if(_type == I64):
			bytes.put_64(_value)
		elif(_type == I32):
			bytes.put_32(_value)
		elif(_type == Double):
			bytes.put_double(_value)
		elif(_type == Str):
			var valUtf8:PackedByteArray = _value.to_utf8_buffer()
			var strLen := valUtf8.size()
			bytes.put_u32(strLen)
			bytes.put_data(valUtf8)
		elif(_type == StrShort):
			var valUtf8:PackedByteArray = _value.to_utf8_buffer()
			var strLen := valUtf8.size()
			bytes.put_u16(strLen)
			bytes.put_data(valUtf8)
		elif(_type == Bool):
			bytes.put_u8(int(_value))
		elif(_type == Float):
			bytes.put_float(_value)
		elif(_type == ByteArray):
			var bytesAmount:int = _value.size()
			bytes.put_u32(bytesAmount)
			bytes.put_data(_value)
		elif(_type == BINS):
			var theBytes:PackedByteArray = _value.bytes.data_array
			var bytesAmount:int = theBytes.size()
			bytes.put_u32(bytesAmount)
			bytes.put_data(theBytes)
		elif(_type == Var):
			bytes.put_var(_value)
		elif(_type == I8):
			bytes.put_8(_value)
		elif(_type == Ignore):
			pass
			
		else:
			assert(false, "IMPLEMENT ME: TYPE: "+str(_type)+" VALUE: "+str(_ar[_indx+1]))
	
	if(expectedFinalSize != bytes.get_size()):
		assert(false, "SIZES DON'T MATCH! expectedFinalSize="+str(expectedFinalSize)+" bytes.get_size()="+str(bytes.get_size()))
	
func saveVar(_var:Variant):
	bytes.append_array(var_to_bytes(_var))

# Start of read functions

func readI64() -> int:
	return bytes.get_64()

func readI32() -> int:
	return bytes.get_32()

func readI8() -> int:
	return bytes.get_8()

func readDouble() -> float:
	return bytes.get_double()
	
func readStr() -> String:
	var utfBufferSize:int = bytes.get_u32()
	var theBuff:PackedByteArray = bytes.get_data(utfBufferSize)[1]
	return theBuff.get_string_from_utf8()
	
func readStrShort() -> String:
	var utfBufferSize:int = bytes.get_u16()
	var theBuff:PackedByteArray = bytes.get_data(utfBufferSize)[1]
	return theBuff.get_string_from_utf8()

func readBool() -> bool:
	return bool(bytes.get_u8())

func readFloat() -> float:
	return bytes.get_float()

func readByteArray() -> PackedByteArray:
	var bufferSize:int = bytes.get_u32()
	var theAr:PackedByteArray = bytes.get_data(bufferSize)[1]
	return theAr

func readBins() -> Bins:
	var bufferSize:int = bytes.get_u32()
	var theAr:PackedByteArray = bytes.get_data(bufferSize)[1]
	return readUncompressed(theAr)

func readVar() -> Variant:
	return bytes.get_var()

# End of read functions

func makeSureComplete() -> bool:
	if(openCounter == 0):
		return true
	assert(false, "YOU FORGOT endSave() OR endLoad() SOMEWHERE")
	return false

static func saveStart(_dat:Array = []) -> Bins:
	var newBins := Bins.new()
	newBins.openCounter += 1
	
	newBins.save(_dat, DO_CHECKSUMS)
	
	return newBins

static func saveStartEnd(_dat:Array = []) -> Bins:
	var newBins := Bins.new()
	newBins.openCounter += 1
	
	newBins.save(_dat, DO_CHECKSUMS)
	
	newBins.endSave()
	return newBins

func saveContinue(_dat:Array = []) -> Bins:
	openCounter += 1
	save(_dat, DO_CHECKSUMS)
	return self

func endSave() -> Bins:
	if(DO_SLOW_CHECKSUMS):
		save([I8, 124])
	openCounter -= 1
	if(openCounter < 0):
		assert(false, "TOO MANY endSave() CALLS")
	return self
	
func loadStart():
	openCounter += 1
	if(DO_CHECKSUMS && readI8() != 123):
		assert(false, "SOMETHING WENT WRONG, loadStart() CHECKSUM FAILED")

func endLoad():
	if(DO_SLOW_CHECKSUMS && readI8() != 124):
		assert(false, "SOMETHING WENT WRONG, endLoad() CHECKSUM FAILED")
	openCounter -= 1
	if(openCounter < 0):
		assert(false, "TOO MANY endLoad() CALLS")

func checkEnded():
	if(openCounter == 0):
		if(bytes.get_size() != bytes.get_position()):
			assert(false, "BAD READ SOMEWHERE! FORGOT TO READ "+str(bytes.get_size() - bytes.get_position())+" BYTES!")
	else:
		assert(false, "BAD! openCounter IS NOT ZERO: "+str(openCounter))
	
func seek(_spot:int):
	bytes.seek(_spot)

func debugStr() -> String:
	return str(bytes)

func getBytesCopy() -> PackedByteArray:
	makeSureComplete()
	return bytes.data_array

func getBytes() -> PackedByteArray:
	makeSureComplete()
	return bytes.data_array

func getBytesSize() -> int:
	makeSureComplete()
	return bytes.get_size()

func getBytesCompressed(_compression: int = FileAccess.COMPRESSION_FASTLZ) -> PackedByteArray:
	makeSureComplete()
	return bytes.data_array.compress(_compression)

func getBytesCompressedSimple() -> PackedByteArray:
	makeSureComplete()
	return bytes.data_array.compress(FileAccess.COMPRESSION_DEFLATE)

static func readCompressedSimple(_bytes:PackedByteArray) -> Bins:
	var newBins := Bins.new()
	newBins.bytes.data_array = _bytes.decompress_dynamic(-1, FileAccess.COMPRESSION_DEFLATE)
	return newBins

func readID() -> String:
	return readStrShort()

func append(_otherBins:Bins):
	bytes.put_data(_otherBins.bytes.data_array)

#_uncompressedSize can be obtained using getBytesSize() on the original data
static func readCompressed(_bytes:PackedByteArray, _uncompressedSize:int, _compression: int = FileAccess.COMPRESSION_FASTLZ) -> Bins:
	var newBins := Bins.new()
	newBins.bytes.data_array = _bytes.decompress(_uncompressedSize, _compression)
	return newBins

static func readUncompressed(_bytes:PackedByteArray) -> Bins:
	var newBins := Bins.new()
	newBins.bytes.data_array = _bytes
	return newBins
	
#static func readUncompressedCopy(_bytes:PackedByteArray) -> Bins:
	#var newBins := Bins.new()
	#newBins.bytes.data_array = _bytes.duplicate()
	#return newBins

#Example usage:
#func saveNetworkData() -> Bins:
	#var data := Bins.saveStart()
	#data.save([
		#Bins.Double, health,
		#Bins.I64, credits,
		#Bins.Str, name,
	#])
	#data.append(inventory.saveNetworkData())
	#data.endSave()
	#return data
#
#func loadNetworkData(_data:Bins):
	#_data.loadStart()
	#health = _data.readDouble()
	#credits = _data.readI64()
	#name = _data.readStr()
	#inventory.loadNetworkData(_data)
	#_data.endLoad()
