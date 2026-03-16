extends InteractEntryBase
class_name InteractEntryText

var text:String = "SOME TEXT MEOW MEOW"

static func create(_text:String) -> InteractEntryText:
	var newEntry := InteractEntryText.new()
	newEntry.text = _text
	return newEntry

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.StrShort, text,
		Bins.StringArrayShort, subCategory,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	text = _data.readStrShort()
	subCategory = _data.readStringArrayShort()
	_data.endLoad()
			
func saveData() -> Dictionary:
	return {
		text = text,
		subCategory = subCategory,
	}

func loadData(_data:Dictionary):
	text = SAVE.loadVar(_data, "text", "")
	subCategory = SAVE.loadVar(_data, "subCategory", subCategory)
	pass
