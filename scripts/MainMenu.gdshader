//shader_type canvas_item;
//
//// Declarar la textura de pantalla como un uniform con hint screen_texture
//uniform sampler2D screen_texture : hint_screen_texture;
//
//// Tamaño del desenfoque ajustable desde el Inspector
//uniform float blur_size : hint_range(0.0, 10.0) = 5.0;
//
//void fragment() {
    //vec4 color = vec4(0.0);
    //float total = 0.0;
//
    //// Bucle para aplicar el desenfoque
    //for (float x = -blur_size; x <= blur_size; x++) {
        //for (float y = -blur_size; y <= blur_size; y++) {
            //// Offset ajustado para cada fragmento alrededor del punto actual
            //vec2 offset = vec2(x, y) * 0.00028;  // Ajustar el valor para un desenfoque adecuado
            //color += texture(screen_texture, SCREEN_UV + offset);
            //total += 1.0;
        //}
    //}
    //// Normalizar el color final
    //color /= total;
    //COLOR = color;
//}
shader_type canvas_item;

// Declarar la textura de pantalla como un uniform con hint screen_texture
uniform sampler2D screen_texture : hint_screen_texture;

// Tamaño del desenfoque ajustable desde el Inspector
uniform float blur_size : hint_range(0.0, 10.0) = 5.0;

// Factor de oscurecimiento ajustable desde el Inspector
uniform float darkness_factor : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 color = vec4(0.0);
    float total = 0.0;

    // Bucle para aplicar el desenfoque
    for (float x = -blur_size; x <= blur_size; x++) {
        for (float y = -blur_size; y <= blur_size; y++) {
            // Offset ajustado para cada fragmento alrededor del punto actual
            vec2 offset = vec2(x, y) * 0.00028;  // Ajustar el valor para un desenfoque adecuado
            color += texture(screen_texture, SCREEN_UV + offset);
            total += 1.0;
        }
    }
    // Normalizar el color final
    color /= total;

    // Oscurecer el color multiplicando por el factor de oscuridad
    color.rgb *= darkness_factor;

    COLOR = color;
}


