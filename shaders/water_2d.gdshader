shader_type canvas_item;
// Textures
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform sampler2D wave;
// Noise parameters
uniform float noise_scale = 100.0;
uniform float wave_time = 0;
// Ocean parameters
uniform float wave_speed = 0.2;
uniform float height_scale = 2.0;
// Cross-section parameters
uniform vec3 world_position = vec3(0.0, 0.0, 0.0); // 3D world position to sample from
uniform float cross_section_width = 10.0;
uniform vec3 cross_section_direction = vec3(1.0, 0.0, 0.0); // Direction of the cross-section plane
uniform float ocean_depth : hint_range(0.1, 10.0) = 3.0;
uniform float view_scale : hint_range(0.1, 100.0) = 1.0;
// ColorRect size (set this from GDScript)
uniform vec2 rect_size = vec2(640, 480);
// Visual parameters
uniform vec4 ocean_color = vec4(0.1, 0.3, 0.6, 0.8);
uniform vec4 foam_color = vec4(0.9, 0.95, 1.0, 1.0);
uniform vec4 deep_color = vec4(0.05, 0.1, 0.3, 1.0);
uniform float foam_threshold : hint_range(0.0, 1.0) = 0.7;


// Simple hash function for noise
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}


// Simple noise function
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal noise with multiple octaves
float fbm(vec2 p, int octaves, float roughness) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    float max_value = 0.0;
    
    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(p * frequency);
        max_value += amplitude;
        amplitude *= roughness;
        frequency *= 2.0;
    }
    
    return value / max_value;
}

// Generate ocean height at a given 3D position
float ocean_height(vec3 world_pos) {
    vec2 sample_pos = fract(world_pos.xz / noise_scale + TIME * wave_speed);
    float height = texture(wave, sample_pos).r;
    return height * height_scale;
}

void fragment() {
    // Convert UV (0-1) to actual pixel coordinates within the ColorRect
    vec2 local_coords = UV * rect_size * view_scale;
    
    // Calculate orthogonal vector to cross_section_direction for the cross-section plane
    vec3 forward = normalize(cross_section_direction);
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 right = normalize(cross(forward, up));
    
    // Convert local coordinates to offsets in the cross-section plane
    float horizontal_offset = (local_coords.x - rect_size.x * 0.5) / 300.0;
    float vertical_offset = -((local_coords.y - rect_size.y * 0.5) / 300.0);
    
    // Calculate 3D world position by offsetting from the base world_position
    vec3 world_pos = world_position + right * horizontal_offset + up * vertical_offset;
    
    // Get ocean surface height at this XZ position
    float surface_height = ocean_height(world_pos);
    
    // Determine if this pixel is above or below the ocean surface
    float depth_below_surface = surface_height - world_pos.y;
    
    if (depth_below_surface > 0.0) {
        // We're below the ocean surface - render water
        float depth_factor = clamp(depth_below_surface / ocean_depth, 0.0, 1.0);


        // Calculate foam based on surface proximity and wave activity
        float foam_noise = fbm(world_pos.xz * 5.0 + TIME * 2.0, 3, 0.6);
        float foam_factor = 1.0 - smoothstep(0.0, 0.3, depth_below_surface);
        foam_factor *= foam_noise;
        
        // Mix colors based on depth and foam
        vec4 water_color = mix(ocean_color, deep_color, depth_factor);
        vec4 final_color = mix(water_color, foam_color, foam_factor * foam_threshold);
        
        // Add some transparency based on depth
        final_color.a = mix(0.8, 1.0, depth_factor);
        
        COLOR = final_color;
    } else {
        // We're above the ocean surface - render sky/air
        float sky_gradient = smoothstep(0.0, rect_size.y, local_coords.y);
        vec4 sky_color = mix(vec4(0.5, 0.7, 1.0, 1.0), vec4(0.8, 0.9, 1.0, 1.0), sky_gradient);
        COLOR = vec4(0,0,0,0);
    }
}
