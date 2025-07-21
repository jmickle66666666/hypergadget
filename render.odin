package main
import rl "vendor:raylib"

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

    for &node in node_list {
        outline_pos :i32= 1

        if &node == selection_hovered {
            outline_pos = 2
        }

        draw_rectangle(
            camera.x + i32(node.x * grid_size) - outline_pos, 
            camera.y + i32(node.y * grid_size) - outline_pos, 
            -1+max(i32(node.w * grid_size), get_text_width(node_type_name(node.type))) + outline_pos*2,
            -1+i32(node.h * grid_size) + outline_pos*2,
            rl.BLACK
        )

        if selection_contains(&node) {
            outline_pos = 3
                draw_rectangle(
                camera.x + i32(node.x * grid_size) - outline_pos, 
                camera.y + i32(node.y * grid_size) - outline_pos, 
                -1+max(i32(node.w * grid_size), get_text_width(node_type_name(node.type))) + outline_pos*2,
                -1+i32(node.h * grid_size) + outline_pos*2,
                rl.WHITE
            )
        }
    }
    for node in node_list {
        rl.DrawRectangleGradientV(
            camera.x + i32(node.x * grid_size)-1, 
            camera.y + i32(node.y * grid_size), 
            max(i32(node.w * grid_size), get_text_width(node_type_name(node.type))),
            i32(node.h * grid_size),
            rl.ColorAlpha(node_type_color(node.type), 0.8), 
            rl.ColorAlpha(rl.ColorBrightness(node_type_color(node.type), -0.25), 0.8)
        )

        draw_text(
            node_type_name(node.type), 
            camera.x + i32(node.x * grid_size)+2,
            camera.y + i32(node.y * grid_size)+2, 
            rl.BLACK
        )
    }

    if rl.IsMouseButtonDown(.LEFT) {
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
            for node in selection {
                outline_pos :i32= 1
                draw_rectangle(
                    camera.x + i32((selection_move.x/grid_size + node.x) * grid_size) - outline_pos, 
                    camera.y + i32((selection_move.y/grid_size + node.y) * grid_size) - outline_pos, 
                    max(i32(node.w * grid_size), get_text_width(node_type_name(node.type))) + outline_pos*2,
                    i32(node.h * grid_size) + outline_pos*2,
                    rl.PINK
                )

                draw_text(
                    node_type_name(node.type), 
                    camera.x + i32((selection_move.x/grid_size + node.x) * grid_size)+2,
                    camera.y + i32((selection_move.y/grid_size + node.y) * grid_size)+2, 
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
