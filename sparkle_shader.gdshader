shader_type canvas_item;
render_mode blend_mix;

// === WATER & COLOR ===
uniform vec4 modulate_color : source_color = vec4(1.0);

// === RIPPLE ===
uniform float base_ripple_frequency : hint_range(1.0, 20.0) = 10.0;
uniform float base_ripple_amplitude : hint_range(0.0, 0.05) = 0.005;
uniform float base_ripple_speed : hint_range(0.0, 10.0) = 3.0;
uniform float ripple_strength : hint_range(0.0, 1.0) = 1.0;

// === STAR PARTICLE SETTINGS - FIRST SET ===
uniform float star_grid_spacing_1 : hint_range(10.0, 500.0) = 30.0;
uniform float star_size_1 : hint_range(1.0, 200.0) = 100.0;
uniform float density_1 : hint_range(0.0, 5.0) = 1.0;
uniform float o_ring_density_1 : hint_range(0.0, 3.0) = 3.0;
uniform float growth_duration_1 : hint_range(0.1, 10.0) = 2.5;
uniform float speed_1 : hint_range(0.1, 5.0) = 1.0;
uniform float min_radius_1 : hint_range(0.0, 1.0) = 0.05;
uniform float max_radius_1 : hint_range(0.0, 1.0) = 0.25;
uniform float particle_size_1 : hint_range(0.1, 5.0) = 1.0;
uniform float particle_thickness_1 : hint_range(0.001, 0.1) = 0.02;
uniform float brightness_1 : hint_range(0.0, 2.0) = 1.0;
uniform bool use_pixelation_1 = true;
uniform float ring_pixel_size_1 : hint_range(0.001, 0.1) = 0.015;
uniform float fragment_pixel_size_1 : hint_range(0.001, 0.1) = 0.015;
uniform float particle_shatter_1 : hint_range(0.0, 1.0) = 0.7;
uniform float particle_cutoff_1 : hint_range(0.7, 1.0) = 0.85;
uniform float particle_blockiness_1 : hint_range(1.0, 30.0) = 10.0;
uniform vec4 star_color_1 : source_color = vec4(1.0);

// === STAR PARTICLE SETTINGS - O2 SET ===
uniform float star_grid_spacing_O2 : hint_range(10.0, 500.0) = 30.0;
uniform float star_size_O2 : hint_range(1.0, 200.0) = 100.0;
uniform float density_O2 : hint_range(0.0, 5.0) = 1.0;
uniform float o_ring_density_O2 : hint_range(0.0, 3.0) = 3.0;
uniform float growth_duration_O2 : hint_range(0.1, 10.0) = 2.5;
uniform float speed_O2 : hint_range(0.1, 5.0) = 1.0;
uniform float min_radius_O2 : hint_range(0.0, 1.0) = 0.05;
uniform float max_radius_O2 : hint_range(0.0, 1.0) = 0.25;
uniform float particle_size_O2 : hint_range(0.1, 5.0) = 1.0;
uniform float particle_thickness_O2 : hint_range(0.001, 0.1) = 0.02;
uniform float brightness_O2 : hint_range(0.0, 2.0) = 1.0;
uniform bool use_pixelation_O2 = true;
uniform float ring_pixel_size_O2 : hint_range(0.001, 0.1) = 0.015;
uniform float fragment_pixel_size_O2 : hint_range(0.001, 0.1) = 0.015;
uniform float particle_shatter_O2 : hint_range(0.0, 1.0) = 0.7;
uniform float particle_cutoff_O2 : hint_range(0.7, 1.0) = 0.85;
uniform float particle_blockiness_O2 : hint_range(1.0, 30.0) = 10.0;
uniform vec4 star_color_O2 : source_color = vec4(1.0);

// === STAR PARTICLE SETTINGS - STAR3 SET ===
uniform float star_grid_spacing_3 : hint_range(10.0, 500.0) = 30.0;
uniform float star_size_3 : hint_range(1.0, 200.0) = 100.0;
uniform float density_3 : hint_range(0.0, 1.0) = 1.0;
uniform float o_ring_density_3 : hint_range(0.0, 3.0) = 3.0;
uniform float growth_duration_3 : hint_range(0.1, 10.0) = 2.5;
uniform float speed_3 : hint_range(0.1, 5.0) = 1.0;
uniform float min_radius_3 : hint_range(0.0, 1.0) = 0.05;
uniform float max_radius_3 : hint_range(0.0, 1.0) = 0.25;
uniform float particle_size_3 : hint_range(0.1, 5.0) = 1.0;
uniform float particle_thickness_3 : hint_range(0.001, 0.1) = 0.02;
uniform float brightness_3 : hint_range(0.0, 2.0) = 1.0;
uniform bool use_pixelation_3 = true;
uniform float ring_pixel_size_3 : hint_range(0.001, 0.1) = 0.015;
uniform float fragment_pixel_size_3 : hint_range(0.001, 0.1) = 0.015;
uniform float particle_shatter_3 : hint_range(0.0, 1.0) = 0.7;
uniform float particle_cutoff_3 : hint_range(0.7, 1.0) = 0.85;
uniform float particle_blockiness_3 : hint_range(1.0, 30.0) = 10.0;
uniform vec4 star_color_3 : source_color = vec4(1.0);

// === STAR PARTICLE SETTINGS - STAR4 SET ===
uniform float star_grid_spacing_4 : hint_range(10.0, 500.0) = 30.0;
uniform float star_size_4 : hint_range(1.0, 200.0) = 100.0;
uniform float density_4 : hint_range(0.0, 1.0) = 1.0;
uniform float o_ring_density_4 : hint_range(0.0, 3.0) = 3.0;
uniform float growth_duration_4 : hint_range(0.1, 10.0) = 2.5;
uniform float speed_4 : hint_range(0.1, 5.0) = 1.0;
uniform float min_radius_4 : hint_range(0.0, 1.0) = 0.05;
uniform float max_radius_4 : hint_range(0.0, 1.0) = 0.25;
uniform float particle_size_4 : hint_range(0.1, 5.0) = 1.0;
uniform float particle_thickness_4 : hint_range(0.001, 0.1) = 0.02;
uniform float brightness_4 : hint_range(0.0, 2.0) = 1.0;
uniform bool use_pixelation_4 = true;
uniform float ring_pixel_size_4 : hint_range(0.001, 0.1) = 0.015;
uniform float fragment_pixel_size_4 : hint_range(0.001, 0.1) = 0.015;
uniform float particle_shatter_4 : hint_range(0.0, 1.0) = 0.7;
uniform float particle_cutoff_4 : hint_range(0.7, 1.0) = 0.85;
uniform float particle_blockiness_4 : hint_range(1.0, 30.0) = 10.0;
uniform vec4 star_color_4 : source_color = vec4(1.0);

// === HELPERS ===
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec4 create_star_effect_1(vec2 star_px, vec4 base,
    float star_spacing, float density, float o_ring_density, float growth_duration, float speed,
    float min_radius, float max_radius, float particle_size, float particle_thickness,
    float brightness, bool use_pixelation, float ring_pixel_size, float fragment_pixel_size,
    float particle_shatter, float particle_cutoff, float particle_blockiness, vec4 star_color) {

    vec2 grid = floor(star_px / star_spacing);
    float seed = hash(grid);
    float effective_density = clamp(density * o_ring_density, 0.0, 1.0);
    if (seed > effective_density) return base;

    vec2 jitter = vec2(hash(grid + 0.1), hash(grid + 2.1)) * 2.0 - 1.0;
    vec2 local = fract(star_px / star_spacing) - vec2(0.5) + jitter * 0.3;

    if (use_pixelation) {
        float px = ring_pixel_size / particle_size;
        local = floor(local / px) * px;
    }

    float appear_time = hash(grid + vec2(5.234, 8.123)) * growth_duration;
    float t = mod(TIME * speed + appear_time, growth_duration);
    float progress = t / growth_duration;

    float radius = mix(min_radius, max_radius * particle_size, progress);
    float len = length(local);
    float inner = radius - particle_thickness * 0.5;
    float outer = radius + particle_thickness * 0.5;
    float ring = smoothstep(outer, radius, len) - smoothstep(radius, inner, len);

    if (progress > particle_cutoff) {
        float shatter_progress = smoothstep(particle_cutoff, 1.0, progress);
        vec2 frag_pos = local;
        if (use_pixelation) {
            float frag_px = fragment_pixel_size / particle_size;
            frag_pos = floor(frag_pos / frag_px) * frag_px;
        }
        float block_scale = particle_blockiness / particle_size;
        vec2 block_pos = floor(frag_pos * block_scale);
        float block_id = hash(block_pos + seed * 10.0);
        float block_cut = step(1.0 - particle_shatter, block_id);
        ring *= 1.0 - (block_cut * shatter_progress);
    }

    float fade = 1.0 - smoothstep(0.9, 1.0, progress);
    float alpha = ring * fade;

    if (alpha < 0.01) return base;
    vec3 star = star_color.rgb * brightness * alpha;
    return vec4(base.rgb + star, base.a);
}

// === MAIN ===
void fragment() {
    vec2 center = vec2(0.5);
    vec2 to_center = UV - center;
    float dist = length(to_center);
    float ripple_wave = sin(dist * base_ripple_frequency - TIME * base_ripple_speed);
    vec2 ripple_offset = normalize(to_center) * ripple_wave * base_ripple_amplitude * ripple_strength;
    vec2 ripple_uv = UV + ripple_offset;

    vec4 base = texture(TEXTURE, ripple_uv);
    base *= modulate_color;

    vec2 star_px = UV * vec2(textureSize(TEXTURE, 0));
    vec4 result = base;

    // Star set 1
    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            vec2 offset = vec2(float(x), float(y)) * star_grid_spacing_1;
            vec2 local_star_px = star_px + offset;
            result = create_star_effect_1(local_star_px, result,
                star_grid_spacing_1, density_1, o_ring_density_1, growth_duration_1, speed_1,
                min_radius_1, max_radius_1, particle_size_1 * star_size_1 / 100.0, particle_thickness_1,
                brightness_1, use_pixelation_1, ring_pixel_size_1, fragment_pixel_size_1,
                particle_shatter_1, particle_cutoff_1, particle_blockiness_1, star_color_1);
        }
    }

    // Star set O2
    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            vec2 offset = vec2(float(x), float(y)) * star_grid_spacing_O2;
            vec2 local_star_px = star_px + offset;
            result = create_star_effect_1(local_star_px, result,
                star_grid_spacing_O2, density_O2, o_ring_density_O2, growth_duration_O2, speed_O2,
                min_radius_O2, max_radius_O2, particle_size_O2 * star_size_O2 / 100.0, particle_thickness_O2,
                brightness_O2, use_pixelation_O2, ring_pixel_size_O2, fragment_pixel_size_O2,
                particle_shatter_O2, particle_cutoff_O2, particle_blockiness_O2, star_color_O2);
        }
    }

    // Star set 3
    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            vec2 offset = vec2(float(x), float(y)) * star_grid_spacing_3;
            vec2 local_star_px = star_px + offset;
            result = create_star_effect_1(local_star_px, result,
                star_grid_spacing_3, density_3, o_ring_density_3, growth_duration_3, speed_3,
                min_radius_3, max_radius_3, particle_size_3 * star_size_3 / 100.0, particle_thickness_3,
                brightness_3, use_pixelation_3, ring_pixel_size_3, fragment_pixel_size_3,
                particle_shatter_3, particle_cutoff_3, particle_blockiness_3, star_color_3);
        }
    }

    // Star set 4
    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            vec2 offset = vec2(float(x), float(y)) * star_grid_spacing_4;
            vec2 local_star_px = star_px + offset;
            result = create_star_effect_1(local_star_px, result,
                star_grid_spacing_4, density_4, o_ring_density_4, growth_duration_4, speed_4,
                min_radius_4, max_radius_4, particle_size_4 * star_size_4 / 100.0, particle_thickness_4,
                brightness_4, use_pixelation_4, ring_pixel_size_4, fragment_pixel_size_4,
                particle_shatter_4, particle_cutoff_4, particle_blockiness_4, star_color_4);
        }
    }

    COLOR = result;
}