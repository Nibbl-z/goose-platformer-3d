uniform bool selected;
uniform bool hovered;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    vec4 pixel = Texel(texture, texture_coords);
    float mult = 1;
    if (selected) { mult = 0.3; }
    if (hovered) { mult = 0.6; }
    return vec4(pixel.r * mult, pixel.g, pixel.b * mult, pixel.a);
}