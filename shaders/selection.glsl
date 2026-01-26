vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    vec4 pixel = Texel(texture, texture_coords);
    number brightness = (pixel.r + pixel.g + pixel.b) / 3.0;

    return vec4(brightness / 2, brightness, brightness / 2, 1.0);
}