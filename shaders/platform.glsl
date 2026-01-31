uniform vec4 tintColor;
uniform bool selected;
uniform bool hovered;
uniform float time;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    vec4 pixel = Texel(texture, texture_coords);
    float v = max(tintColor.r, max(tintColor.g, tintColor.b));
    if ((texture_coords.x <= 0.05 || texture_coords.x >= 0.95 || texture_coords.y <= 0.05 || texture_coords.y >= 0.95) && (hovered || selected)) {
        if (selected) {
            return vec4(0.1, (sin((time * 5) + texture_coords.y) + 1) / 6 + 0.4, 0.1, 1.0);
        } else {
            return vec4(0.3, (sin((time * 5) + texture_coords.y) + 1) / 8 + 0.6, 0.3, 1.0);
        }
    } else {
        return vec4(pixel.r * tintColor.r, pixel.g * tintColor.g, pixel.b * tintColor.b, 1.0);
    }
}