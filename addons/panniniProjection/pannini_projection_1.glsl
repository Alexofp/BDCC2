#[compute]
#version 450

// Use a standard workgroup size of 64
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Use rgba16f format for future HDR support, or use rgba8 if your project will not have HDR support
layout(rgba16f, set = 0, binding = 0) uniform restrict readonly image2D color_image;
layout(rgba16f, set = 0, binding = 1) uniform restrict writeonly image2D texture_image;

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

    // Based on http://tksharpless.net/vedutismo/Pannini/panini.pdf (see section 4 for following
    // calculation)

    // Obtain h and v coordinates by converting from 0, n to 0, 1 range, then from 0, 1 to -1, 1
    vec2 hv = vec2(texel + 0.5) / vec2(resolution) * 2.0 - 1.0; // 0.5 needs to be added to texel
    // position for accurate conversion, else texels will shift slightly

    // Retrieve image scale from push constant, then apply to hv coords
    float imageScale = params.data2.x;
    hv = hv * imageScale;

    // Retrieve Pannini distance from push constant, which controls the form of the projection and
    // can be any non-negative value:
    // rectilinear projection/no effect = 0.0,
    // stereographic Pannini projection = 1.0,
    // for values > 1.0, the projection will tend toward orthographic Pannini
    float d = params.data1.z;

    // Calculate cosphi, s and phi
    float k = hv.x * hv.x / ((d + 1.0) * (d + 1.0));
    float discriminant = k * k * d * d - (k + 1.0) * (k * d * d - 1.0);
    float cosPhi = (-k * d + sqrt(discriminant)) / (k + 1.0);

    float s = (d + 1.0) / (d + cosPhi);

    float phi = atan(hv.x, s * cosPhi);

    // Retrieve the amount of "hard" vertical compression from push constant
    float compression = params.data1.w;

    // Calculate theta with given compression value,
    // atan(hv.y, s) = no compression,
    // atan(hv.y * cosPhi) = max compression
    float theta = mix(atan(hv.y, s), atan(hv.y * cosPhi), compression);

    // Reproject 3d cylindrical image back onto view plane:
    // Cartesian coordinates of point P on cylinder surface = sin(phi), tan(theta), -cos(phi),
    // Screen coordinates of P = P.x / -P.z, P.y / -P.z = sin(phi) / cos(phi), tan(theta) / cos(phi)
    vec2 hvReprojected = vec2(sin(phi) / cosPhi, tan(theta) / cosPhi);

    // Convert back to texel space
    ivec2 texelReprojected = ivec2((hvReprojected * 0.5 + 0.5) * resolution);

    // Sample image by the new coords, then write result to texture by the original coords
    vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
    color.rgb = imageLoad(color_image, texelReprojected).rgb;
    imageStore(texture_image, texel, color);
}
