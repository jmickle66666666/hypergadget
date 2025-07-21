package main
import rl "vendor:raylib"

MouseType :: enum {
    None,
    Select,
    UI,
    Resize,
    Moving,
}

mouse_type : MouseType = .None

mouse_texture:rl.Texture

mouse_render :: proc() {
    mpos :[2]f32= rl.GetMousePosition()

    mouse_texture_index := 0

    // switch mouse_type {
    //     case .None: draw_text("N/A", i32(mpos.x), i32(mpos.y + 16), rl.ORANGE)
    //     case .Resize: draw_text("Resize", i32(mpos.x), i32(mpos.y + 16), rl.ORANGE)
    //     case .Select: draw_text("Select", i32(mpos.x), i32(mpos.y + 16), rl.ORANGE)
    //     case .UI: draw_text("UI", i32(mpos.x), i32(mpos.y + 16), rl.ORANGE)
    // }

    switch mouse_type {
        case .None: mouse_texture_index = 0
        case .Resize: mouse_texture_index = 1
        case .Select: mouse_texture_index = 2
        case .UI: mouse_texture_index = 0
        case .Moving: mouse_texture_index = 3
    }

    rl.DrawTextureRec(mouse_texture, {f32(mouse_texture_index * 32), 0, 32, 32}, mpos, rl.WHITE)
}