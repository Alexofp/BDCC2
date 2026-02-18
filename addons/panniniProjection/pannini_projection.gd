@tool
class_name PanniniProjection
extends CompositorEffect
## Applies the Pannini projection to the viewport.
##
## This effect can be used to display wide fields of view with less apparent distortion than is seen
## in a traditional rectilinear projection. This is achieved by projecting the 2D viewport image
## onto a 3D virtual cylinder, then simulating a second camera some distance behind the original
## that projects the cylindrical image back onto the original 2D plane. See the
## [url=http://tksharpless.net/vedutismo/Pannini/panini.pdf]original document[/url] for more
## information. [br]
## [br]
## Note: This effect currently only applies to the viewport's colour texture, meaning that the
## viewport's other textures (depth, velocity) will become inaccurate after this effect has been
## applied. This can cause other effects which rely on the accuracy of these textures, such as
## temporal anti-aliasing, to display improperly. [br]
## [br]
## Note: With this effect applied to a WorldEnvironment node and enabled in the editor viewport, the
## apparent positions of objects and gizmos will no longer match the position that must be selected
## to manipulate them. Disabling this effect while performing these tasks is recommended.
## Alternatively, removing the @tool annotation from this class will cause the effect to only be
## applied at runtime.
## @experimental


## The distance along the Z axis by which the Pannini projection's virtual camera is offset from the
## real camera. Higher values apply more horizontal compression, narrowing the image and reducing
## stretching of objects at its edges. However, higher values also slightly reduce resolution at the
## centre of the image. [br]
## [br]
## Note: As the value of this property is increased beyond [code]0.0[/code], a border of blank
## texels is produced at the edges of the image. These blank texels can be cropped using
## [member image_zoom].
@export_range(0.0, 35.0, 0.01, "or_greater", "exp") var distance: float = 1.0
## The amount of "hard" vertical compression applied to the image. [br]
## [br]
## If this value is [code]0.0[/code], no vertical compression is applied, resulting in the [b]basic
## Pannini projection[/b]. This means that straight lines passing through the centre of the image
## will still appear straight, but straight lines passing horizontally across the image may appear
## curved. [br]
## [br]
## If this value is [code]1.0[/code], maximum compression is applied, resulting in the [b]general
## Pannini projection[/b]. This means that straight lines passing through the centre of the image
## may no longer appear straight, but straight lines passing horizontally across the image will not
## appear curved. [br]
## [br]
## Intermediate values smoothly interpolate between these two states.
@export_range(0.0, 1.0, 0.01) var vertical_compression: float = 0.0
## Zoom in on the centre of the image by lowering this value. This is useful to hide blank texels
## beyond the bounds of the viewport. [br]
## [br]
## Note: Because this does not change the resolution of the image, setting this property below
## [code]1.0[/code] will effectively reduce the viewport resolution, and texels beyond the bounds
## of the viewport will also still be rendered. This reduction in effective resolution can be offset
## by increasing the value of the project setting [code]rendering/scaling_3d/scale[/code] above
## [code]1.0[/code]. However, this can have a [i]significant[/i] performance impact. On supported
## hardware, using the texture mode of the project setting [code]rendering/vrs[/code] with a
## suitable texture may help reduce the performance impact of both an increased rendering scale and
## the rendering of texels outside the viewport. [br]
## [br]
## Note: To get the viewport's vertical FOV while this property is set to a value less than
## [code]1.0[/code], call [method PanniniProjection.get_visible_fovy].
@export_range(0.7, 1.0, 0.01) var image_zoom: float = 1.0

var _rd: RenderingDevice
var _shader_1: RID
var _shader_2: RID
var _pipeline_1: RID
var _pipeline_2: RID
var _context: StringName = &"PanniniProjection"
var _texture: StringName = &"PanniniTexture"


func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	_rd = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_initialize_compute)


# When using RenderingDevice, we need to perform manual memory management to prevent potential
# memory leaks. To do so, we attempt to free the RID of an object when receiving the notification
# that the object is about to be deleted
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _shader_1.is_valid():
			_rd.free_rid(_shader_1)
		if _shader_2.is_valid():
			_rd.free_rid(_shader_2)
		# Freeing the shaders will also free dependent objects such as the pipelines


#region Code in this region runs on the rendering thread.
# Compile shaders during initialisation
func _initialize_compute() -> void:
	_rd = RenderingServer.get_rendering_device()
	if not _rd:
		return

	var shader_file := load("res://addons/panniniProjection/pannini_projection_1.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	_shader_1 = _rd.shader_create_from_spirv(shader_spirv)
	if _shader_1.is_valid():
		_pipeline_1 = _rd.compute_pipeline_create(_shader_1)

	shader_file = load("res://addons/panniniProjection/pannini_projection_2.glsl")
	shader_spirv = shader_file.get_spirv()
	_shader_2 = _rd.shader_create_from_spirv(shader_spirv)
	if _shader_2.is_valid():
		_pipeline_2 = _rd.compute_pipeline_create(_shader_2)


# Called by the rendering thread every frame.
func _render_callback(p_effect_callback_type: EffectCallbackType, 
		p_render_data: RenderData) -> void:
	if _rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and \
			_pipeline_1.is_valid() and _pipeline_2.is_valid():
		# Get our render scene buffers object, this gives us access to our render buffers.
		# Note that implementation differs per renderer hence the need for the cast.
		var render_scene_buffers := p_render_data.get_render_scene_buffers()
		if render_scene_buffers:
			# Get our render size, this is the 3D render resolution!
			var size: Vector2i = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			# If the texture for storing the result of our shader exists, check it's the correct
			# resolution. If it isn't, discard it
			if render_scene_buffers.has_texture(_context, _texture):
				var tf: RDTextureFormat = render_scene_buffers.get_texture_format(_context,
						 _texture)
				if tf.width != size.x or tf.height != size.y:
					render_scene_buffers.clear_context(_context)
			# If the texture doesn't exist, create it
			if not render_scene_buffers.has_texture(_context, _texture):
				var usage_bits: int = (
						RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT 
						| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT 
						| RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
				)
				render_scene_buffers.create_texture(_context, _texture, 
						RenderingDevice.DATA_FORMAT_R16G16B16A16_UNORM, usage_bits, 
						RenderingDevice.TEXTURE_SAMPLES_1, size, 1, 1, true, false)

			# In each dimension, set the number of GPU workgroups the compute shader will use
			@warning_ignore("integer_division")
			var x_groups := (size.x - 1) / 8 + 1
			@warning_ignore("integer_division")
			var y_groups := (size.y - 1) / 8 + 1
			var z_groups := 1

			# Create push constant.
			# Must be aligned to 16 bytes and be in the same order as defined in the shader.
			var push_constant := PackedFloat32Array([
					size.x,
					size.y,
					distance,
					vertical_compression,
					image_zoom,
					0.0,
					0.0,
					0.0,
				])

			# Get RIDs for our image uniforms
			var color_image: RID = render_scene_buffers.get_color_layer(0)
			var texture_image: RID = render_scene_buffers.get_texture_slice(_context, _texture, 
					0, 0, 1, 1)

			# Create a cached uniform set for the first shader, which will be cleared if the context
			# changes
			var uniform_1 := RDUniform.new()
			uniform_1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
			uniform_1.binding = 0
			uniform_1.add_id(color_image)
			var uniform_2 := RDUniform.new()
			uniform_2.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
			uniform_2.binding = 1
			uniform_2.add_id(texture_image)
			var uniform_set := UniformSetCacheRD.get_cache(_shader_1, 0, [uniform_1, uniform_2])

			# Run the first compute shader
			var compute_list := _rd.compute_list_begin()
			_rd.compute_list_bind_compute_pipeline(compute_list, _pipeline_1)
			_rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
			_rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), 
					push_constant.size() * 4)
			_rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
			_rd.compute_list_end()

			# Create the same uniform set with swapped bindings for the second shader (the swapped
			# bindings are not essential, it's just to keep the image uniforms in input to output
			# order in the shader code!)
			uniform_1 = RDUniform.new()
			uniform_1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
			uniform_1.binding = 1
			uniform_1.add_id(color_image)
			uniform_2 = RDUniform.new()
			uniform_2.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
			uniform_2.binding = 0
			uniform_2.add_id(texture_image)
			uniform_set = UniformSetCacheRD.get_cache(_shader_2, 0, [uniform_1, uniform_2])

			# Run the second compute shader (which simply copies the results of the first shader
			# back to the color buffer)
			compute_list = _rd.compute_list_begin()
			_rd.compute_list_bind_compute_pipeline(compute_list, _pipeline_2)
			_rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
			_rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), 
					push_constant.size() * 4)
			_rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
			_rd.compute_list_end()
#endregion


## Returns the vertical field of view of the [i]visible area[/i] of the Pannini-projected image (in
## degrees) associated with the given horizontal field of view (in degrees), aspect ratio and
## [member image_zoom]. This is in contrast to [method Projection.get_fovy], which returns the
## vertical FOV of the entire image, including area potentially cropped out via
## [member image_zoom]. [br]
## [br]
## Note: As with [method Projection.get_fovy], [param aspect] is expected to be 1 divided by the X:Y
## aspect ratio.
static func get_visible_fovy(fovx: float, aspect: float, zoom: float) -> float:
	return rad_to_deg(2.0 * atan(tan(deg_to_rad(fovx) / 2.0) * (aspect * zoom)))
