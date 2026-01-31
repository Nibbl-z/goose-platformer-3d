uniform vec4 tintColor;
uniform bool selected;
uniform bool hovered;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    vec4 pixel = Texel(texture, texture_coords);

    if ((texture_coords.x <= 0.05 || texture_coords.x >= 0.95 || texture_coords.y <= 0.05 || texture_coords.y >= 0.95) && (hovered || selected)) {
        if (selected) {
            return vec4(0.0, 1.0, 0.0, 1.0);
        } else {
            return vec4(0.4, 0.8, 0.4, 1.0);
        }
    } else {
        return vec4(pixel.r * tintColor.r, pixel.g * tintColor.g, pixel.b * tintColor.b, 1.0);
    }
}