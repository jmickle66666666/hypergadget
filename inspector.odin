package main
import rl "vendor:raylib"
import "core:strings"

INSPECTOR_WIDTH :: 200
inspector_open := true

inspector_textbox_edit := false

inspector_hovering :: proc() -> bool {
    if !inspector_open { return false }
    mpos := rl.GetMousePosition()
    if mpos.x > f32(SCREEN_WIDTH - INSPECTOR_WIDTH) {
        return true
    }
    return false
}

inspector_draw :: proc() {
    if rl.IsKeyPressed(.TAB) {
        inspector_open =! inspector_open
    }

    if !inspector_open {
        rl.GuiPanel({f32(SCREEN_WIDTH - INSPECTOR_WIDTH), 0, f32(INSPECTOR_WIDTH), 0}, "inspector")    
        return
    } 
    rl.GuiPanel({f32(SCREEN_WIDTH - INSPECTOR_WIDTH), 0, f32(INSPECTOR_WIDTH), f32(SCREEN_HEIGHT)}, "inspector")

    pos :rl.Rectangle= {f32(SCREEN_WIDTH - INSPECTOR_WIDTH) + 8, 24, f32(INSPECTOR_WIDTH), 16}

    if len(selection) == 1 {
        gadget := selection[0]
        rl.GuiLabel(pos, strings.unsafe_string_to_cstring(gadget_type_name(gadget.type)))
        pos.y += 16
        if gadget.type == .Text {
            // config := &config_text_map[gadget.guid]
            // text_cstring := strings.unsafe_string_to_cstring(config.text)
            // // defer delete(text_cstring)
            // if rl.GuiTextBox(pos, text_cstring, 10, inspector_textbox_edit) { inspector_textbox_edit =! inspector_textbox_edit }
            // config.text = string(text_cstring)
            
            // i need to do my own textbox implementation :(
        }
    }
}