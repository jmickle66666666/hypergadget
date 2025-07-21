package main
import rl "vendor:raylib"
import "core:slice"

camera :[2]i32

render_grid := false

zoom_in :: proc() {
    mpos :[2]f32= rl.GetMousePosition()
    mpos.x -= f32(camera.x)
    mpos.y -= f32(camera.y)

    ampos := mpos / f32(grid_size)
    font_size_change(+1)
    bmpos := mpos / f32(grid_size)
    dmpos := (bmpos - ampos) * f32(grid_size)
    camera.x += i32(dmpos.x)
    camera.y += i32(dmpos.y)
}

zoom_out :: proc() {
    mpos :[2]f32= rl.GetMousePosition()
    mpos.x -= f32(camera.x)
    mpos.y -= f32(camera.y)

    ampos := mpos / f32(grid_size)
    font_size_change(-1)
    bmpos := mpos / f32(grid_size)
    dmpos := (bmpos - ampos) * f32(grid_size)
    camera.x += i32(dmpos.x)
    camera.y += i32(dmpos.y)
}

render :: proc() {

    if render_grid {
        w:=rl.GetScreenWidth()
        h:=rl.GetScreenHeight()
        for i:=camera.x % i32(grid_size); i < w; i += i32(grid_size) {
            rl.DrawLine(i, 0, i, h, rl.DARKGRAY)
        }
        for i:=camera.y % i32(grid_size); i < h; i += i32(grid_size) {
            rl.DrawLine(0, i, w, i, rl.DARKGRAY)
        }
    }

    if rl.IsKeyDown(.UP) { camera.y += 1 }
    if rl.IsKeyDown(.DOWN) { camera.y -= 1 }
    if rl.IsKeyDown(.LEFT) { camera.x += 1 }
    if rl.IsKeyDown(.RIGHT) { camera.x -= 1 }

    if rl.IsKeyDown(.SPACE) {
        imdelta :[2]i32= {i32(rl.GetMouseDelta().x), i32(rl.GetMouseDelta().y)}
        
        camera += imdelta
    }

    for &gadget in gadget_list {
        outline_pos :i32= 1

        if &gadget == selection_hovered {
            outline_pos = 2
        }

        draw_rectangle(
            camera.x + i32(gadget.x * grid_size) - outline_pos, 
            camera.y + i32(gadget.y * grid_size) - outline_pos, 
            -1+max(i32(gadget.w * grid_size), get_text_width(gadget_type_name(gadget.type))) + outline_pos*2,
            -1+i32(gadget.h * grid_size) + outline_pos*2,
            rl.BLACK
        )

        if selection_contains(&gadget) {
            outline_pos = 3
                draw_rectangle(
                camera.x + i32(gadget.x * grid_size) - outline_pos, 
                camera.y + i32(gadget.y * grid_size) - outline_pos, 
                -1+max(i32(gadget.w * grid_size), get_text_width(gadget_type_name(gadget.type))) + outline_pos*2,
                -1+i32(gadget.h * grid_size) + outline_pos*2,
                rl.WHITE
            )
        }
    }
    for &gadget in gadget_list {
        alpha :f32= 0.8
        if !slice.contains(solve_queue[:], &gadget) {
            alpha = 0.2
        }
        rl.DrawRectangleGradientV(
            camera.x + i32(gadget.x * grid_size)-1, 
            camera.y + i32(gadget.y * grid_size), 
            max(i32(gadget.w * grid_size), get_text_width(gadget_type_name(gadget.type))),
            i32(gadget.h * grid_size),
            rl.ColorAlpha(gadget_type_color(gadget.type), alpha), 
            rl.ColorAlpha(rl.ColorBrightness(gadget_type_color(gadget.type), -0.25), alpha)
        )

        draw_text(
            gadget_type_name(gadget.type), 
            camera.x + i32(gadget.x * grid_size)+2,
            camera.y + i32(gadget.y * grid_size)+2, 
            rl.BLACK
        )

        outline_pos :i32= -2

        draw_rectangle(
            camera.x + i32((gadget.x + gadget.w - 1) * grid_size) - outline_pos, 
            camera.y + i32((gadget.y + gadget.h - 1) * grid_size) - outline_pos, 
            -1+i32(grid_size) + outline_pos*2,
            -1+i32(grid_size) + outline_pos*2,
            rl.ColorAlpha(rl.BLACK, 0.3)
        )
    }

    if rl.IsMouseButtonDown(.LEFT) {
        if mouse_type == .Resize && resize_gadget != nil {
            outline_pos :i32= 3
            draw_rectangle(
                camera.x + i32(resize_gadget.x * grid_size) - outline_pos, 
                camera.y + i32(resize_gadget.y * grid_size) - outline_pos, 
                -1+max(i32(resize_gadget.w * grid_size), get_text_width(gadget_type_name(resize_gadget.type))) + outline_pos*2,
                -1+i32(resize_gadget.h * grid_size) + outline_pos*2,
                rl.GREEN
            )
        }

        if selection_drawing_box && !ui_hovered() {
            draw_rectangle(
                camera.x + i32(selection_click_start.x), 
                camera.y + i32(selection_click_start.y), 
                i32(selection_move.x),
                i32(selection_move.y),
                rl.WHITE
            )

            rl.DrawRectangle(
                camera.x + i32(selection_click_start.x), 
                camera.y + i32(selection_click_start.y), 
                i32(selection_move.x),
                i32(selection_move.y),
                rl.ColorAlpha(rl.WHITE, 0.2)
            )
        } else {
            for gadget in selection {
                outline_pos :i32= 1
                draw_rectangle(
                    camera.x + i32((selection_move.x/grid_size + gadget.x) * grid_size) - outline_pos, 
                    camera.y + i32((selection_move.y/grid_size + gadget.y) * grid_size) - outline_pos, 
                    max(i32(gadget.w * grid_size), get_text_width(gadget_type_name(gadget.type))) + outline_pos*2,
                    i32(gadget.h * grid_size) + outline_pos*2,
                    rl.PINK
                )

                draw_text(
                    gadget_type_name(gadget.type), 
                    camera.x + i32((selection_move.x/grid_size + gadget.x) * grid_size)+2,
                    camera.y + i32((selection_move.y/grid_size + gadget.y) * grid_size)+2, 
                    rl.PINK
                )
            }
        }
    }
}

draw_rectangle :: proc(x:i32, y:i32, w:i32, h:i32, color:rl.Color) {
    rl.DrawLine(x, y, x + w, y, color)
    rl.DrawLine(x, y+h+1, x + w, y+h, color)
    rl.DrawLine(x, y, x, y+h+1, color)
    rl.DrawLine(x+w, y, x + w, y+h, color)
}
