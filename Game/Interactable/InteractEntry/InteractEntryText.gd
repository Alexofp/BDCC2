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
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	text = _data.readStrShort()
	_data.endLoad()
			
func saveData() -> Dictionary:
	return {
		text = text,
	}

func loadData(_data:Dictionary):
	text = SAVE.loadVar(_data, "text", "")
	pass
