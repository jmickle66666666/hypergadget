package main
import rl "vendor:raylib"

UI_MENU_SPACING :: 12

ui_hovered_timer :int= 0

ButtonCommand :: struct {
    x:int,
    y:int,
    label:string
}
ui_button_commands : [dynamic]ButtonCommand

button :: proc(x:int, y:int, label:string) -> bool {
    append(&ui_button_commands, (ButtonCommand){x, y, label})

    x :i32= i32(x)
    y :i32= i32(y)
    w := get_text_width(label) + 12
    h := i32(font_size + 12)

    impos :[2]i32= {i32(mouse_position().x), i32(mouse_position().y)}
    hovered := impos.x >= x && impos.x < x+w && impos.y >= y && impos.y < y+h 
    if hovered { 
        mouse_type = .UI
    }

    if hovered && rl.IsMouseButtonPressed(.LEFT) {
        return true
    }

    return false
}

button_render :: proc(x:int, y:int, label:string) {
    x :i32= i32(x)
    y :i32= i32(y)
    w := get_text_width(label) + 12
    h := i32(font_size + 12)

    impos :[2]i32= {i32(mouse_position().x), i32(mouse_position().y)}
    hovered := impos.x >= x && impos.x < x+w && impos.y >= y && impos.y < y+h 

    if hovered && !rl.IsMouseButtonDown(.LEFT) {
        rl.DrawRectangle(camera.x + x, camera.y + y, w, h, rl.WHITE)
        draw_rectangle(camera.x + x, camera.y + y, w, h, rl.BLACK)
        draw_text(label, camera.x + x + 7, camera.y + y + 7, rl.BLACK)
    } else {
        rl.DrawRectangle(camera.x + x, camera.y + y, w, h, rl.BLACK)
        draw_rectangle(camera.x + x, camera.y + y, w, h, rl.WHITE)
        draw_text(label, camera.x + x + 7, camera.y + y + 7, rl.WHITE)
    }
}

Menu :: struct {
    x:int,
    y:int,
    items : [dynamic]MenuItem
}

MenuItem :: struct {
    label:string,
    onclick : proc(),
}

ui_menu :Menu = {}

ui_menu_clear :: proc() {
    clear(&ui_menu.items)
}

ui_menu_start :: proc(x:int, y:int) {
    ui_menu_clear()
    ui_menu.x = x
    ui_menu.y = y
}

ui_menu_add :: proc(label:string, onclick : proc()) {
    append(&ui_menu.items, (MenuItem){label, onclick})
}

ui_update :: proc() {
    clear(&ui_button_commands)

    hit_any := false
    for item, i in ui_menu.items {
        if button(ui_menu.x, ui_menu.y + i * (UI_MENU_SPACING + font_size), item.label) {
            hit_any = true
            item.onclick()
        }
    }
    if rl.IsMouseButtonPressed(.LEFT) && !hit_any {
        ui_menu_clear()
    }
}

ui_hovered :: proc() -> bool {
    return ui_hovered_timer > 0
}

ui_render :: proc() {

    y := SCREEN_HEIGHT - font_size
    for &toast in ui_toast_list {
        if toast.time > 0 { 
            toast.time -= 1 
            draw_text(toast.message, SCREEN_WIDTH - get_text_width(toast.message), i32(y), rl.BLACK)
            draw_text(toast.message, SCREEN_WIDTH - get_text_width(toast.message), i32(y-1), rl.WHITE)
            y -= font_size
        }
    }

    for button_command in ui_button_commands {
        button_render(button_command.x, button_command.y, button_command.label)
    }
}

toast :: proc(message:string) {
    for &toast in ui_toast_list {
        if toast.time == 0 {
            toast.time = 180
            toast.message = message
            return
        }
    }

    append(&ui_toast_list, (Toast){message, 180})
}

Toast :: struct {
    message : string,
    time : int
}

ui_toast_list : [dynamic]Toast = {}
