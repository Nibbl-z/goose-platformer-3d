uniform float hue;

// i cannot comprehend the math for this,
// this is adapted from https://stackoverflow.com/questions/51203917/math-behind-hsv-to-rgb-conversion-of-colors

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    float s = texture_coords.x;
    float v = 1 - texture_coords.y;

    float r;
    float g;
    float b;

    float i = floor(hue * 6);
    float f = hue * 6 - i;
    float p = v * (1 - s);
    float q = v * (1 - f * s);
    float t = v * (1 - (1 - f) * s);

    if (mod(i, 6.0) == 0) { r = v; g = t; b = p; }
    if (mod(i, 6.0) == 1) { r = q; g = v; b = p; }
    if (mod(i, 6.0) == 2) { r = p; g = v; b = t; }
    if (mod(i, 6.0) == 3) { r = p; g = q; b = v; }
    if (mod(i, 6.0) == 4) { r = t; g = p; b = v; }
    if (mod(i, 6.0) == 5) { r = v; g = p; b = q; }

    return vec4(r, g, b, 1.0);
}