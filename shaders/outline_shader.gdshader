// Source: https://godotshaders.com/shader/outline-that-disrespects-boundaries/
// by fupi
// Simple modification of this GDQuest shader (https://godotshaders.com/shader/shader/2d-outline-stroke/)
// with portions of this other shader by Juulpower (https://godotshaders.com/shader/shader/2d-outline-inline/)
// Modifications:
// - hsandt: adapted to Godot 4 (hint_color -> source_color)
// - hsandt: renamed parameters line_... -> outline_... for clarity
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1);
uniform float outline_thickness : hint_range(0, 20) = 0.0;
uniform bool add_margins = true;

void vertex() {
    if (add_margins) {
        VERTEX += (UV * 2.0 - 1.0) * outline_thickness;
    }
}

void fragment() {
    vec2 uv = UV;
    
    if (add_margins) {
        vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(outline_thickness * 2.0));
        
        uv = (uv - texture_pixel_size * outline_thickness) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
        
        if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
            COLOR.a = 0.0;
        } else {
            COLOR = texture(TEXTURE, uv);
        }
    } else {
        COLOR = texture(TEXTURE, uv);
    }
    
    vec2 size = TEXTURE_PIXEL_SIZE * outline_thickness;
    
    if (outline_thickness < 0.1) {
        vec4 color = texture(TEXTURE, uv);
        COLOR = color;
    } else {
        float outline = texture(TEXTURE, uv + vec2(-size.x, 0)).a;
        outline += texture(TEXTURE, uv + vec2(0, size.y)).a;
        outline += texture(TEXTURE, uv + vec2(size.x, 0)).a;
        outline += texture(TEXTURE, uv + vec2(0, -size.y)).a;
        outline += texture(TEXTURE, uv + vec2(-size.x * 0.866, size.y * 0.5)).a;
        outline += texture(TEXTURE, uv + vec2(-size.x * 0.5, size.y * 0.866)).a;
        outline += texture(TEXTURE, uv + vec2(size.x * 0.866, size.y * 0.5)).a;
        outline += texture(TEXTURE, uv + vec2(size.x * 0.5, size.y * 0.866)).a;
        outline += texture(TEXTURE, uv + vec2(-size.x * 0.866, -size.y * 0.5)).a;
        outline += texture(TEXTURE, uv + vec2(-size.x * 0.5, -size.y * 0.866)).a;
        outline += texture(TEXTURE, uv + vec2(size.x * 0.866, -size.y * 0.5)).a;
        outline += texture(TEXTURE, uv + vec2(size.x * 0.5, -size.y * 0.866)).a;
        outline = min(outline, 1.0);
        
        vec4 color = texture(TEXTURE, uv);
        COLOR = mix(color, outline_color, outline - color.a);
    }
}