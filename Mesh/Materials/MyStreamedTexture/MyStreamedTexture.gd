extends Texture2D
class_name MyStreamedTexture

## Doesn't seem to work sadly. The materials don't update unless they're forced to

var internalTexture:Texture2D
const EMPTY_TEXTURE = preload("res://Mesh/Textures/EmptyTexture.png")

var texturePath:String = ""

static func make(_path:String) -> MyStreamedTexture:
	var theTexture := MyStreamedTexture.new()
	theTexture.setTexturePath(_path)
	return theTexture

func setTexturePath(_path:String):
	texturePath = _path
	#var theTexture := load(_path)
	var theTexture := await ThreadedResourceLoader.asyncLoadRequest(_path)
	if(texturePath != _path):
		return
	internalTexture = theTexture
	#print("LOADEWD")
	emit_changed()
	#changed.emit()

func _get_height():
	if(internalTexture):
		return internalTexture.get_height()
	return EMPTY_TEXTURE.get_height()

func _get_width():
	if(internalTexture):
		return internalTexture.get_width()
	return EMPTY_TEXTURE.get_width()

func _has_alpha():
	if(internalTexture):
		return internalTexture.has_alpha()
	return EMPTY_TEXTURE.has_alpha()
	
func _is_pixel_opaque(x, y):
	if(internalTexture):
		return internalTexture.is_pixel_opaque(x, y)
	return EMPTY_TEXTURE.is_pixel_opaque(x, y)
	
func _get_size():
	if(internalTexture):
		return internalTexture.get_size()
	return EMPTY_TEXTURE.get_size()

func _get_rid():
	if(internalTexture):
		return internalTexture.get_rid()
	return EMPTY_TEXTURE.get_rid()
