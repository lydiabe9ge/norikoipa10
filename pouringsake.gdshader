shader_type canvas_item;
render_mode blend_mix;

// === BASE FADE ===
uniform float fade_height : hint_range(0.0, 1.0) = 1.0;
uniform float sharpness : hint_range(0.01, 10.0) = 5.0;
uniform float transparency : hint_range(0.0, 1.0) = 1.0;
uniform vec4 modulate_color : source_color = vec4(1.0);

// === PARTICLE RING VISUALS ===
uniform vec4 o_ring_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform float min_radius : hint_range(0.001, 0.5) = 0.01;
uniform float max_radius : hint_range(0.1, 1.0) = 0.3;
uniform float ring_size : hint_range(0.1, 2.0) = 1.0;
uniform float ring_thickness : hint_range(0.001, 0.1) = 0.03;
uniform float growth_speed : hint_range(0.1, 5.0) = 1.0;
uniform float pixel_size : hint_range(0.001, 0.1) = 0.02;
uniform int max_rings : hint_range(1, 5) = 2;

// === PARTICLE SETTINGS ===
uniform float particle_density : hint_range(0.01, 1.0) = 0.3; // Particles per unit length
uniform float particle_size : hint_range(0.001, 0.1) = 0.02;
uniform float particle_randomness : hint_range(0.0, 1.0) = 0.5; // Position variation
uniform float particle_flicker : hint_range(0.0, 1.0) = 0.2; // Brightness variation

// === FLOAT ANIMATION ===
uniform float float_amplitude : hint_range(0.0, 0.5) = 0.02;
uniform float float_speed : hint_range(0.1, 5.0) = 1.0;

// === OFFSET & PERSPECTIVE ===
uniform float o_ring_offset_x : hint_range(-1.0, 1.0) = 0.0;
uniform float o_ring_offset_y : hint_range(-1.0, 1.0) = 0.0;
uniform float o_ring_scale_x : hint_range(0.1, 2.0) = 1.0;
uniform float o_ring_scale_y : hint_range(0.1, 2.0) = 1.0;

// === I-CUT MASK SETTINGS ===
uniform float i_cut_width : hint_range(0.001, 0.3) = 0.02;
uniform float i_cut_width_fade : hint_range(0.0, 1.0) = 0.5;
uniform float i_cut_height : hint_range(0.001, 1.0) = 1.0;
uniform float i_cut_offset_x : hint_range(-1.0, 1.0) = 0.0;
uniform float i_cut_offset_y : hint_range(-1.0, 1.0) = 0.0;

// Hash function for pseudo-random numbers
float hash(float n) { return fract(sin(n)*43758.5453); }

void fragment() {
    vec4 tex = texture(TEXTURE, UV) * modulate_color;

    // === BASE ALPHA FADE FROM BOTTOM ===
    float alpha_mask = smoothstep(0.0, fade_height, 1.0 - UV.y);
    alpha_mask = pow(alpha_mask, sharpness);
    tex.a *= alpha_mask * transparency;

    // === APPLY SIZE SCALING ===
    float scaled_min_radius = min_radius * ring_size;
    float scaled_max_radius = max_radius * ring_size;
    float scaled_thickness = ring_thickness * ring_size;

    // === FLOAT OFFSET ===
    float float_offset = sin(TIME * float_speed) * float_amplitude;

    // === PIXEL-LOCKED POSITION WITH FLOAT ===
    vec2 center = vec2(0.5 + o_ring_offset_x, 0.5 + o_ring_offset_y + float_offset);
    vec2 pixel_uv = floor(UV / pixel_size) * pixel_size;
    vec2 offset = pixel_uv - center;
    offset.x *= o_ring_scale_x;
    offset.y *= o_ring_scale_y;
    float dist = length(offset);
    float angle = atan(offset.y, offset.x);

    // === PARTICLE RING ANIMATION ===
    float ring = 0.0;

    for (int i = 0; i < max_rings; i++) {
        // Calculate time offset for each ring
        float t = fract(TIME * growth_speed + float(i)/float(max_rings));

        // Calculate radius and fade for this ring
        float radius = mix(scaled_min_radius, scaled_max_radius, t);
        float fade = smoothstep(0.0, 0.2, t) * (1.0 - smoothstep(0.8, 1.0, t));

        // Particle effect - only draw at particle positions
        float circumference = 2.0 * 3.141592 * radius;
        float particle_spacing = 1.0 / (circumference * particle_density);
        float particle_pos = mod(angle + TIME * 0.5 + float(i)*0.7, particle_spacing) / particle_spacing;

        // Add randomness to particle positions
        float particle_id = floor((angle + TIME * 0.5 + float(i)*0.7) / particle_spacing);
        float random_offset = (hash(particle_id) - 0.5) * particle_randomness * particle_spacing;

        // Calculate particle shape
        float inner = radius - scaled_thickness * 0.5;
        float outer = radius + scaled_thickness * 0.5;
        float radial = smoothstep(inner - particle_size, inner, dist) * (1.0 - smoothstep(outer, outer + particle_size, dist));
        float angular = smoothstep(0.0, particle_size*5.0, abs(particle_pos - 0.5 + random_offset));

        // Add flickering effect
        float flicker = 1.0 - particle_flicker * hash(particle_id + TIME);

        ring = max(ring, radial * angular * fade * flicker);
    }

    // === I-CUT MASK WITH FLOAT OFFSET ===
    vec2 i_center = vec2(0.5 + i_cut_offset_x, 0.5 + i_cut_offset_y + float_offset);
    vec2 i_space = pixel_uv - i_center;

    // Calculate width fade based on distance from center
    float width_fade = 1.0 - i_cut_width_fade * smoothstep(0.0, scaled_max_radius, dist);
    float current_cut_width = i_cut_width * width_fade;

    float i_cut = 1.0 - (step(-current_cut_width * 0.5, i_space.x) * step(i_space.x, current_cut_width * 0.5)
                      * step(-i_cut_height * 0.5, i_space.y) * step(i_space.y, i_cut_height * 0.5));
    ring *= i_cut;

    // === FINAL OUTPUT ===
    float ring_alpha = ring * o_ring_color.a * transparency;
    COLOR = mix(tex, vec4(o_ring_color.rgb * brightness, ring_alpha), ring_alpha);
}
