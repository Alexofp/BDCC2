extends RefCounted
class_name SexOrgasmInfo

var charID:String = ""
var causerID:String = ""

var type:int = SexOrgasmType.Generic
var cause:int = SexOrgasmCause.Generic
var intensity:int = SexOrgasmIntensity.Normal

func saveData() -> Dictionary:
	return {
		c = charID,
		ca = causerID,
		t = type,
		cau = cause,
		i = intensity,
	}

func loadData(_data:Dictionary):
	charID = SAVE.loadStr(_data, "c")
	causerID = SAVE.loadStr(_data, "ca")
	type = SAVE.loadInt(_data, "t", SexOrgasmType.Generic)
	cause = SAVE.loadInt(_data, "cau", SexOrgasmCause.Generic)
	intensity = SAVE.loadInt(_data, "i", SexOrgasmIntensity.Normal)
