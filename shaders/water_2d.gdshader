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

// Visual parameters
uniform vec4 ocean_color = vec4(0.1, 0.3, 0.6, 0.8);
uniform vec4 foam_color = vec4(0.9, 0.95, 1.0, 1.0);
uniform vec4 deep_color = vec4(0.05, 0.1, 0.3, 1.0);
uniform float foam_threshold : hint_range(0.0, 1.0) = 0.7;

// Generate ocean height at a given 3D position
float ocean_height(vec3 world_pos) {
        vec2 sample_pos = fract(world_pos.xz / noise_scale + TIME * wave_speed);
	float height  = texture(wave, sample_pos).r;

	// float height  = texture(wave, world_pos.xz / noise_scale + wave_time * wave_speed).r;
    return height * height_scale - 1.5;
}

void fragment() {
    vec2 uv = UV;
    
    // Calculate orthogonal vector to cross_section_direction for the cross-section plane
    vec3 forward = normalize(cross_section_direction);
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 right = normalize(cross(forward, up));
    
    // Convert UV to offsets in the cross-section plane
    // UV.x represents horizontal distance along the cross-section
    // UV.y represents vertical height (Y-axis)
    float horizontal_offset = (uv.x - 0.5) * cross_section_width / 2.0;
    float vertical_offset = ((1.0-uv.y) - 0.5) * cross_section_width / 2.0;
    
    // Calculate 3D world position by offsetting from the base world_position
    vec3 world_pos = world_position + right * horizontal_offset + up * vertical_offset;
    
    // Get ocean surface height at this XZ position
    float surface_height = ocean_height(world_pos);
    
    // Determine if this pixel is above or below the ocean surface
    float depth_below_surface = surface_height - world_pos.y;
    
    if (depth_below_surface > 0.0) {
        // We're below the ocean surface - render water
        float depth_factor = clamp(depth_below_surface / ocean_depth, 0.0, 1.0);
        
        // Mix colors based on depth and foam
        vec4 water_color = mix(ocean_color, deep_color, depth_factor);
        
        // Add some transparency based on depth
        water_color.a = mix(0.6, 1.0, depth_factor);
        
        COLOR = water_color;
    } else {
        // We're above the ocean surface - render sky/air
        // Create a simple gradient sky
        float sky_gradient = smoothstep(0.0, 1.0, uv.y);
        vec4 sky_color = mix(vec4(0.5, 0.7, 1.0, 1.0), vec4(0.8, 0.9, 1.0, 1.0), sky_gradient);
        COLOR = sky_color;
    }
}
