extends RefCounted
class_name BaseSkinData

var skinType: String = "fur"
var skinColor: Color = Color.WHITE

func makeCopy() -> BaseSkinData:
	var newData = BaseSkinData.new()
	newData.skinType = skinType
	newData.skinColor = skinColor
	return newData
