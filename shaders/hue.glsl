// i cannot comprehend the math for this,
// this is adapted from https://stackoverflow.com/questions/51203917/math-behind-hsv-to-rgb-conversion-of-colors
// (and #simplified because s and v is always 1 here)

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    float hue = texture_coords.y;

    float r;
    float g;
    float b;

    float i = floor(hue * 6);
    float f = hue * 6 - i;
    float q = (1 - f);
    float t = (1 - (1 - f));

    if (mod(i, 6.0) == 0) { r = 1; g = t; b = 0; }
    if (mod(i, 6.0) == 1) { r = q; g = 1; b = 0; }
    if (mod(i, 6.0) == 2) { r = 0; g = 1; b = t; }
    if (mod(i, 6.0) == 3) { r = 0; g = q; b = 1; }
    if (mod(i, 6.0) == 4) { r = t; g = 0; b = 1; }
    if (mod(i, 6.0) == 5) { r = 1; g = 0; b = q; }

    return vec4(r, g, b, 1.0);
}