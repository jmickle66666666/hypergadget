package main
import rl "vendor:raylib"
import "core:fmt"
import "core:slice"

selection_hovered : ^Node 
selection : [dynamic]^Node

selection_clicknode : ^Node

selection_click_start : [2]int
selection_move : [2]int

selection_drawing_box : bool

selection_update :: proc() {
    if ui_hovered() { selection_drawing_box=false; return }
    impos :[2]int= mouse_position()
    selection_hovered = nil
    for &node in node_list {
        if node.x * grid_size <= impos.x && node.y * grid_size <= impos.y &&
           (node.x + node.w) * grid_size > impos.x && (node.y + node.h) * grid_size > impos.y {
            selection_hovered = &node
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

        selection_clicknode = selection_hovered
        selection_click_start = {impos.x, impos.y}
    }

    if rl.IsMouseButtonDown(.LEFT) {
        selection_move = impos - selection_click_start
    }

    if rl.IsMouseButtonReleased(.LEFT) {
        if selection_drawing_box {
            if !rl.IsKeyDown(.LEFT_SHIFT) { clear(&selection) }

            x1 := min(impos.x, selection_click_start.x)
            x2 := max(impos.x, selection_click_start.x)
            y1 := min(impos.y, selection_click_start.y)
            y2 := max(impos.y, selection_click_start.y)

            for &node in node_list {
                if selection_contains(&node) { continue }
                if node.x * grid_size > x1 && node.x * grid_size < x2 - node.w * grid_size &&
                   node.y * grid_size > y1 && node.y * grid_size < y2 - node.h * grid_size {
                    append(&selection, &node)
                }
            }
        } else {
            for &node in selection {
                node.x += selection_move.x / grid_size
                node.y += selection_move.y / grid_size
            }
        }
    }

    if rl.IsKeyPressed(.DELETE) {
        for node in selection {
            i, found := slice.linear_search(node_list[:], node^)
            unordered_remove(&node_list, i)
        }
        clear(&selection)
    }
}

selection_contains :: proc(node:^Node) -> bool {
    for &selected_node in selection {
        if node == selected_node {
            return true
        }
    }
    return false
}