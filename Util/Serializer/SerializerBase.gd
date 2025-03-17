extends RefCounted
class_name SerializerBase

func saveVar(_theKey:String, _theValue):
	assert(false, "Not implemented")

func shouldLoad(_theKey:String) -> bool:
	return true

func loadVar(_theKey:String, _default):
	assert(false, "Not implemented")
	return null

func loadIntoVar(_obj:Object, _theVar:String, _default):
	if(shouldLoad(_theVar)):
		_obj.set(_theVar, loadVar(_theVar, _default))

func getData() -> Dictionary:
	return {}
