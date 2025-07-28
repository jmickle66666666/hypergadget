package main
import rl "vendor:raylib"
import "core:fmt"
import "core:slice"

selection_hovered : ^Gadget 
selection : [dynamic]^Gadget

selection_clickgadget : ^Gadget

selection_click_start : [2]int
selection_move : [2]int

selection_drawing_box : bool

selection_mousecheck :: proc() {
    if mouse_type == .None {
        mouse_type = .Select
    }

    if mouse_type == .Select {
        if selection_hovered != nil {
            mouse_type = .Moving
        }
    }
}

selection_update :: proc() {
    if mouse_type != .Select && mouse_type != .Moving { 
        if rl.IsMouseButtonPressed(.LEFT) {
            selection_drawing_box = false
            clear(&selection)
        }
        return 
    }
    impos :[2]int= mouse_position()
    selection_hovered = nil
    for &gadget in gadget_list {
        if gadget.x * grid_size <= impos.x && gadget.y * grid_size <= impos.y &&
           (gadget.x + gadget.w) * grid_size > impos.x && (gadget.y + gadget.h) * grid_size > impos.y {
            selection_hovered = &gadget
            break
        }
    }

    if rl.IsMouseButtonPressed(.LEFT) {
        if selection_contains(selection_hovered) {
            selection_drawing_box = false
        } else {
            if selection_hovered == nil {
                selection_drawing_box = true
            } else {
                selection_drawing_box = false
                if !rl.IsKeyDown(.LEFT_SHIFT) { clear(&selection) }
                append(&selection, selection_hovered)
            }
        }

        selection_clickgadget = selection_hovered
        selection_click_start = {impos.x, impos.y}
    }

    if rl.IsMouseButtonDown(.LEFT) {
        selection_move = impos - selection_click_start
    }

    if rl.IsMouseButtonReleased(.LEFT) && !inspector_hovering() {
        if selection_drawing_box {
            if !rl.IsKeyDown(.LEFT_SHIFT) { clear(&selection) }

            x1 := min(impos.x, selection_click_start.x)
            x2 := max(impos.x, selection_click_start.x)
            y1 := min(impos.y, selection_click_start.y)
            y2 := max(impos.y, selection_click_start.y)

            for &gadget in gadget_list {
                if selection_contains(&gadget) { continue }
                if gadget.x * grid_size > x1 && gadget.x * grid_size < x2 - gadget.w * grid_size &&
                   gadget.y * grid_size > y1 && gadget.y * grid_size < y2 - gadget.h * grid_size {
                    append(&selection, &gadget)
                }
            }
        } else {
            tmov := selection_move / grid_size
            for &gadget in selection {
                gadget.x += tmov.x
                gadget.y += tmov.y
            }

            solve_build_queue()
        }
    }

    if rl.IsKeyPressed(.DELETE) {
        for gadget in selection {
            i, found := slice.linear_search(gadget_list[:], gadget^)
            unordered_remove(&gadget_list, i)
        }
        clear(&selection)
    }
}

selection_contains :: proc(gadget:^Gadget) -> bool {
    for &selected_gadget in selection {
        if gadget == selected_gadget {
            return true
        }
    }
    return false
}