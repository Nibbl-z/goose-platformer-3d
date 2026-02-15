
uniform float time;
uniform bool enabled;
uniform bool selected;
uniform bool hovered;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453 + cos(time));
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    float size = 5;
    float extra = 0;
    float offset = 0.09;
    float mult = 0.4;
    if (enabled) {
        size = 15;
        offset = 0.03;
        extra = 0.4;
        texture_coords = texture_coords + sin(time) / 5;
        mult = 1;
    }
    vec2 rounded = vec2(floor(texture_coords.x * size) / size, floor(texture_coords.y * size) / size);
    vec2 diff = vec2(rounded.x + offset, rounded.y + offset) - texture_coords;
    float dist = sqrt(pow(diff.x, 2) + pow(diff.y, 2)) * (size / 5);

    if ((texture_coords.x <= 0.05 || texture_coords.x >= 0.95 || texture_coords.y <= 0.05 || texture_coords.y >= 0.95) && (hovered || selected)) {
        if (selected) {
            return vec4(0.1, (sin((time * 5) + texture_coords.y) + 1) / 6 + 0.4, 0.1, 1.0);
        } else {
            return vec4(0.3, (sin((time * 5) + texture_coords.y) + 1) / 8 + 0.6, 0.3, 1.0);
        }
    } else {
        return vec4(
            cos((time * 2) + random(rounded)) / 8 + dist + extra, 
            (sin((time * 5) + random(rounded)) / 8 + .5 + dist + extra) * mult, 
            cos((time * 3) + random(rounded)) / 8 + dist + extra, 
        1);
    }
}