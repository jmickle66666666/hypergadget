package main
import "core:strings"
import rl "vendor:raylib"
import "core:fmt"

font :rl.Font

font_sizes :[6]int= { 8, 16, 24, 32, 48, 64 }
font_size := 16

fonts :[6]rl.Font

font_texture:rl.Texture

// determine this by image size isntead
// also put this shit in a struct so different fonts etc
// i kinda wanna make a Font Tool for the kerning data.........
// but everything being monospace for this game whould be fine
font_character_width : i32 : 6
font_character_height : i32 : 8
font_spacing : i32 = 8

load_fonts :: proc(font_paths:..cstring) {
    for i:=0; i< len(font_sizes); i+= 1 {
        fonts[i] = rl.LoadFontEx(font_paths[min(i, len(font_paths)-1)], i32(font_sizes[i]), nil, 0)
    }
}

// draw_text_centered :: proc(text: string, x: i32, y: i32, color: rl.Color) {
//     w := get_text_width(text)
//     x := x - w/2
//     draw_text(text, x, y, color)
// }

font_size_change :: proc(delta:int) {
    index := 0
    for size, i in font_sizes {
        if font_size == size {
            index = i
            break
        }
    }
    index += delta
    index = clamp(index, 0, len(font_sizes)-1)
    font = fonts[index]
    font_size = font_sizes[index]
    grid_size = font_size + 4
}

draw_text :: proc(text: string, x: i32, y: i32, color: rl.Color, uppercase:bool = false) {

    rl.DrawTextEx(font, strings.unsafe_string_to_cstring(text), {f32(x), f32(y)}, f32(font_size), 0.0, color)
    return

    // x := x
    // y := y
    // startx := x
    // last_rune :rune= 0
    // for codepoint, _ in text {

    //     codepoint := (uppercase && codepoint >= 97 && codepoint <= 122) ? codepoint - 32 : codepoint

    //     kern := font_pair_kerning(last_rune, codepoint)
    //     x += kern

    //     if codepoint != '\n' {
    //         draw_rune(codepoint, x, y, color)
    //     }

    //     size := font_rune_size(codepoint)
    //     x += size

    //     if codepoint == '\n' {
    //         x = startx
    //         y += font_character_height
    //     }

    //     last_rune = codepoint
    // }
}

get_text_width :: proc(text: string) -> i32 {

    return i32(rl.MeasureTextEx(font, strings.unsafe_string_to_cstring(text), f32(font_size), 0.0)[0])

    // x :i32= 1
    // last_rune :rune= 0
    // size:i32
    // for codepoint, _ in text {

    //     kern := font_pair_kerning(last_rune, codepoint)
    //     x += kern

    //     size = font_rune_size(codepoint)
    //     x += size

    //     last_rune = codepoint
    // }
    // return x
}

draw_rune :: proc(rune: rune, x:i32, y: i32, color: rl.Color) {
    rl.DrawTextureRec(
        font_texture, 
        {cast(f32)(rune % 16) * cast(f32)font_character_width, cast(f32)(rune / 16) * cast(f32)font_character_height, cast(f32)font_character_width, cast(f32)font_character_height},
        {cast(f32)x, cast(f32)y},
        color,
    )
}

font_rune_size :: proc(_rune: rune) -> i32 {
    switch _rune {
    case '\'': return 2
    case 't': return 4
    case '.': return 2
    case ':': return 2
    case ',': return 2
    case '!': return 2
    case 'l': return 3
    case 'i': return 2
    case 'f': return 4
    case 'T': return 6
    case 'c': return 4
    case 'k': return 4
    case 'a': return 6
    case 'm': return 6
    case 'w': return 6
    case 'V': return 6
    case 'W': return 6
    case 'M': return 6
    case 'v': return 6
    case 'I': return 4
    case 'X': return 6
    case ' ': return 3
    case '_': return 6
    }
    return 5
}

font_pair_kerning :: proc(charA: rune, charB: rune) -> i32 {
    if charA == 'n' && charB == '\'' { return -1 }
    if charA == '\'' && charB == 's' { return -1 }
    if charA == 'y' && charB == '\'' { return -1 }
    if charA == 'T' && charB == 'w' { return -1 }
    if charA == 'T' && charB == 'o' { return -1 }
    if charA == 'T' && charB == 'i' { return -1 }
    if charA == 'l' && charB == 'v' { return -1 }
    if charA == 'a' && charB == 'v' { return -1 }
    if charA == 'r' && charB == 'j' { return -1 }
    return 0
}
