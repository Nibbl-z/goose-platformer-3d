
uniform float time;
uniform bool enabled;
uniform bool selected;
uniform bool hovered;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453 + cos(time));
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    float size = 5.0;
    float extra = 0.0;
    float offset = 0.09;
    float mult = 0.4;

    if (hovered) {
        size = 10.0;
        offset = 0.06;
        extra = 0.1;
        mult = 0.6;
    }

    if (enabled || selected) {
        size = 15.0;
        offset = 0.03;
        extra = 0.4;
        texture_coords = texture_coords + sin(time) / 5.0;
        mult = 1.0;
    }

    

    vec2 rounded = vec2(floor(texture_coords.x * size) / size, floor(texture_coords.y * size) / size);
    vec2 diff = vec2(rounded.x + offset, rounded.y + offset) - texture_coords;
    float dist = sqrt(pow(diff.x, 2.0) + pow(diff.y, 2.0)) * (size / 5.0);

    return vec4(
        cos((time * 2.0) + random(rounded)) / 8.0 + dist + extra, 
        (sin((time * 5.0) + random(rounded)) / 8.0 + .5 + dist + extra) * mult, 
        cos((time * 3.0) + random(rounded)) / 8.0 + dist + extra, 
    1);
}