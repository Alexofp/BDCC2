#[compute]
#version 450

// Use a standard workgroup size of 64
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Use rgba16f format for future HDR support, or use rgba8 if your project will not have HDR support
layout(rgba16f, set = 0, binding = 0) uniform restrict readonly image2D texture_image;
layout(rgba16f, set = 0, binding = 1) uniform restrict writeonly image2D color_image;

// Push constant data is packed into vec4s here to prevent any byte alignment mistakes
layout(push_constant, std430) uniform Params {
    vec4 data1; // xy = raster size, z = pannini distance, w = hard vertical compression
    vec4 data2; // x = image scale
} params;

// The code we want to execute in each invocation
void main() {
    ivec2 texel = ivec2(gl_GlobalInvocationID.xy);
    ivec2 resolution = ivec2(params.data1.xy);

    // Prevent reading/writing out of bounds
    if (texel.x >= resolution.x || texel.y >= resolution.y) {
        return;
    }

    // Load image from texture_image and store to color_image
    vec4 color = vec4(imageLoad(texture_image, texel));
    imageStore(color_image, texel, color);
}
