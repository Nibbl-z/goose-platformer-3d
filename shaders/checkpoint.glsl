
uniform float time;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453 + cos(time));
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    float size = 15;
    vec2 rounded = vec2(floor(texture_coords.x * size) / size, floor(texture_coords.y * size) / size);
    vec2 diff = vec2(rounded.x + 0.03, rounded.y + 0.03) - texture_coords;
    float dist = sqrt(pow(diff.x, 2) + pow(diff.y, 2)) * (size / 5);

    return vec4(cos((time * 2) + random(rounded)) / 8 + dist, sin((time * 5) + random(rounded)) / 8 + .5 + dist, cos((time * 3) + random(rounded)) / 8 + dist, 1);
}