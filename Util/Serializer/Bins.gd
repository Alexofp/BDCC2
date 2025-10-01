extends RefCounted
class_name Bins # Binary Saver
# Heavily inspired by https://github.com/vysker/bytekruncher with an attempt to make it more perfomant

const DO_CHECKSUMS = true
const DO_SLOW_CHECKSUMS = true

var bytes: PackedByteArray = PackedByteArray()
var readSpot:int = 0
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
	Var, #Variant
	I8,
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
		elif(_type == Var):
			pointer += var_to_bytes(_ar[_indx+1]).size()
		elif(_type == I8):
			pointer += 1
			
		else:
			assert(false, "IMPLEMENT ME: TYPE: "+str(_type)+" VALUE: "+str(_ar[_indx+1]))
		
	return pointer

func save(_ar:Array, _addSaveMarker:bool = false):
	var arSize:int = _ar.size()
	if(arSize % 2 == 1):
		assert(false, "LAST VALUE IS MISSING")
	var cSize:int = bytes.size()
	var toReserve:= getSizeOf(_ar)
	if(_addSaveMarker):
		toReserve += 1
	
	bytes.resize(cSize + toReserve)
	
	var pointer:int = cSize
	
	if(_addSaveMarker):
		bytes.encode_s8(0, 123)
		pointer += 1
	
	for _ii in range(int(arSize/2.0)):
		var _indx:int = _ii * 2
		var _type:int = _ar[_indx]
		var _value:Variant = _ar[_indx+1]
		
		if(_type == I64):
			bytes.encode_s64(pointer, _value)
			pointer += 8
		elif(_type == I32):
			bytes.encode_s32(pointer, _value)
			pointer += 4
		elif(_type == Double):
			bytes.encode_double(pointer, _value)
			pointer += 8
		elif(_type == Str):
			var valUtf8:PackedByteArray = _value.to_utf8_buffer()
			var strLen := valUtf8.size()
			bytes.encode_u32(pointer, strLen)
			pointer += 4
			for _i in range(strLen):
				bytes.set(pointer+_i, valUtf8[_i])
			pointer += strLen
		elif(_type == StrShort):
			var valUtf8:PackedByteArray = _value.to_utf8_buffer()
			var strLen := valUtf8.size()
			bytes.encode_u16(pointer, strLen)
			pointer += 2
			for _i in range(strLen):
				bytes.set(pointer+_i, valUtf8[_i])
			pointer += strLen
		elif(_type == Bool):
			bytes.encode_u8(pointer, int(_value))
			pointer += 1
		elif(_type == Float):
			bytes.encode_float(pointer, _value)
			pointer += 4
		elif(_type == ByteArray):
			var bytesAmount:int = _value.size()
			bytes.encode_u32(pointer, bytesAmount)
			pointer += 4
			for _i in range(bytesAmount):
				bytes.set(pointer+_i, _value[_i])
		elif(_type == Var):
			var _howMuchBytes := bytes.encode_var(pointer, _value)
			pointer += _howMuchBytes
		elif(_type == I8):
			bytes.encode_s8(pointer, _value)
			pointer += 1
			
		else:
			assert(false, "IMPLEMENT ME: TYPE: "+str(_type)+" VALUE: "+str(_ar[_indx+1]))

func saveVar(_var:Variant):
	bytes.append_array(var_to_bytes(_var))

# Start of read functions

func readI64() -> int:
	var val:int = bytes.decode_s64(readSpot)
	readSpot += 8
	return val

func readI32() -> int:
	var val:int = bytes.decode_s32(readSpot)
	readSpot += 4
	return val

func readI8() -> int:
	var val:int = bytes.decode_s8(readSpot)
	readSpot += 1
	return val

func readDouble() -> float:
	var val:float = bytes.decode_double(readSpot)
	readSpot += 8
	return val
	
func readStr() -> String:
	var utfBufferSize:int = bytes.decode_u32(readSpot)
	readSpot += 4
	var theBuff := bytes.slice(readSpot, readSpot+utfBufferSize)
	readSpot += utfBufferSize
	return theBuff.get_string_from_utf8()
	
func readStrShort() -> String:
	var utfBufferSize:int = bytes.decode_u16(readSpot)
	readSpot += 2
	var theBuff := bytes.slice(readSpot, readSpot+utfBufferSize)
	readSpot += utfBufferSize
	return theBuff.get_string_from_utf8()

func readBool() -> bool:
	var val:float = bytes.decode_u8(readSpot)
	readSpot += 1
	return val

func readFloat() -> float:
	var val:float = bytes.decode_float(readSpot)
	readSpot += 4
	return val

func readByteArray() -> PackedByteArray:
	var bufferSize:int = bytes.decode_u32(readSpot)
	readSpot += 4
	var theAr:PackedByteArray = bytes.slice(readSpot, readSpot+bufferSize)
	readSpot += bufferSize
	return theAr

func readVar() -> Variant:
	var varSize:int = bytes.decode_var_size(readSpot)
	var theResult = bytes.decode_var(readSpot)
	readSpot += varSize
	return theResult

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
	if(openCounter == 0):
		if(bytes.size() != readSpot):
			assert(false, "BAD READ SOMEWHERE! FORGOT TO READ "+str(bytes.size() - readSpot)+" BYTES!")

func seek(_spot:int):
	readSpot = _spot

func debugStr() -> String:
	return str(bytes)

func getBytesCopy() -> PackedByteArray:
	makeSureComplete()
	return bytes.duplicate()

func getBytesRef() -> PackedByteArray:
	makeSureComplete()
	return bytes

func getBytesSize() -> int:
	makeSureComplete()
	return bytes.size()

func getBytesCompressed(_compression: int = FileAccess.COMPRESSION_FASTLZ) -> PackedByteArray:
	makeSureComplete()
	return bytes.compress(_compression)

func getBytesCompressedSimple() -> PackedByteArray:
	makeSureComplete()
	return bytes.compress(FileAccess.COMPRESSION_DEFLATE)

static func readCompressedSimple(_bytes:PackedByteArray) -> Bins:
	var newBins := Bins.new()
	newBins.bytes = _bytes.decompress_dynamic(-1, FileAccess.COMPRESSION_DEFLATE)
	return newBins

func appendWithID(_id:String, _otherBins:Bins):
	var theIDArray := _id.to_utf8_buffer()
	var theStringBuffer := PackedByteArray()
	theStringBuffer.resize(2)
	theStringBuffer.encode_u16(0, theIDArray.size())
	theStringBuffer.append_array(theIDArray)
	theStringBuffer.append_array(_otherBins.bytes)
	bytes.append_array(theStringBuffer)

func readID() -> String:
	return readStrShort()

func append(_otherBins:Bins):
	bytes.append_array(_otherBins.bytes)

#_uncompressedSize can be obtained using getBytesSize() on the original data
static func readCompressed(_bytes:PackedByteArray, _uncompressedSize:int, _compression: int = FileAccess.COMPRESSION_FASTLZ) -> Bins:
	var newBins := Bins.new()
	newBins.bytes = _bytes.decompress(_uncompressedSize, _compression)
	return newBins

# Doesn't duplicate your data!
static func readUncompressed(_bytes:PackedByteArray) -> Bins:
	var newBins := Bins.new()
	newBins.bytes = _bytes
	return newBins
	
static func readUncompressedCopy(_bytes:PackedByteArray) -> Bins:
	var newBins := Bins.new()
	newBins.bytes = _bytes.duplicate()
	return newBins

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
