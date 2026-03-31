extends MemoryBase
class_name MemorySimple

var name:String = "Some memory"
var desc:String = "Something happened"

func getName() -> String:
	return name
	
func getDescription() -> String:
	return desc

static func create(_id:String, _name:String, _desc:String) -> MemorySimple:
	var theMemory := MemorySimple.new()
	theMemory.id = _id
	theMemory.name = _name
	theMemory.desc = _desc
	return theMemory
