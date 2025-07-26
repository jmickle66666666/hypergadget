package main
import "core:fmt"
import rl "vendor:raylib"
import "settings"
import "core:mem"
import "core:math"

grid_size := font_size
DEBUG_MODE := true

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

time := 0

main :: proc() {
    if DEBUG_MODE {
        mem.tracking_allocator_init(&tracking_allocator, context.allocator)
        defer mem.tracking_allocator_destroy(&tracking_allocator)
        context.allocator = mem.tracking_allocator(&tracking_allocator)
        init()
    } else {
        init()
    }
}

init :: proc () {
    fmt.println("hypergadget")
    
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "hypergadget")

    mouse_texture = rl.LoadTexture("mouse.png")

    rl.SetTargetFPS(60)

    settings.init()
    rl.SetWindowPosition(i32(settings.cfg.window_x), i32(settings.cfg.window_y))

    load_fonts(
        "fonts/Px437_ATI_SmallW_6x8.ttf",
        "fonts/XanhMono-Regular.ttf",
    )
    font_size_change(0)

    rl.HideCursor()

    for !rl.WindowShouldClose() {
        time += 1

        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        if rl.IsKeyPressed(.PAGE_UP) || rl.GetMouseWheelMove() > 0 { zoom_in() }
        if (rl.IsKeyPressed(.PAGE_DOWN) || rl.GetMouseWheelMove() < 0) && font_size > 3 { zoom_out() }

        ui_hovered_timer -= 1

        if rl.IsMouseButtonPressed(.RIGHT) {
            impos :[2]int= mouse_position()
            ui_menu_start(impos.x+4, impos.y+4)

            ui_menu_add("Add Gadget", proc() {
                ui_menu_clear()
                ui_menu_add("Label", proc() { gadget_create_at_mouse(.Label) })
                ui_menu_add("Ping", proc() { gadget_create_at_mouse(.Ping) })
                ui_menu_add("Root", proc() { gadget_create_at_mouse(.Root) })
                ui_menu_add("Chain", proc() { gadget_create_at_mouse(.Chain) })
                ui_menu_add("Print", proc() { gadget_create_at_mouse(.Print) })
                ui_menu_add("TextFile", proc() { gadget_create_at_mouse(.TextFile) })
                ui_menu_add("ReverseText", proc() { gadget_create_at_mouse(.ReverseText) })
            })

            ui_menu_add("Toggle Grid", proc() {
                ui_menu_clear()
                render_grid =! render_grid
            })

            ui_menu_add("Run", proc() {
                solve_traverse()
            })
        }

        if !rl.IsMouseButtonDown(.LEFT) && !rl.IsMouseButtonReleased(.LEFT) {
            mouse_type = .None
            selection_mousecheck()
            resize_mousecheck()
        }

        ui_update()
        selection_update()
        resize_update()
        render()
        ui_render()
        debug_update()
        debug_draw()
        mouse_render()

        rl.EndDrawing()
    }

    window_position := rl.GetWindowPosition()
    settings.cfg.window_x = int(window_position.x)
    settings.cfg.window_y = int(window_position.y)
    settings.save()

    rl.CloseWindow()
}

mouse_position :: proc() -> [2]int {
    mpos :[2]f32= rl.GetMousePosition()
    mpos.x -= f32(camera.x)
    mpos.y -= f32(camera.y)
    // dont ask
    // if mpos.x < 0 { mpos.x += 1.0 }
    // if mpos.y < 0 { mpos.y += 1.0 }
    return {int(math.round(mpos.x)), int(math.round(mpos.y))}
}

mouse_screen_position :: proc() -> [2]int {
    mpos :[2]f32= rl.GetMousePosition()
    return {int(mpos.x), int(mpos.y)}
}