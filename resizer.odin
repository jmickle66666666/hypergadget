package main
import rl "vendor:raylib"
import "core:fmt"

resize_mousecheck :: proc() {
    impos :[2]int= mouse_position()
    tmpos :[2]int = impos / grid_size
    if impos.x < 0 { tmpos.x -= 1 }
    if impos.y < 0 { tmpos.y -= 1 }

    for &gadget in gadget_list {
        if gadget.x + gadget.w == tmpos.x + 1 && gadget.y + gadget.h == tmpos.y + 1 {
            mouse_type = .Resize
            resize_gadget = &gadget
        }
    }
}

resize_drag_start := 0
resize_gadget :^Gadget= nil

resize_update :: proc() {
    if mouse_type != .Resize { return }

    impos :[2]int= mouse_position()
    tmpos :[2]int = impos / grid_size

    if rl.IsMouseButtonPressed(.LEFT) {
        resize_drag_start = tmpos.x
    }

    if rl.IsMouseButtonDown(.LEFT) {
        new_pos := max(resize_gadget.x + 1, tmpos.x)
        resize_gadget.w = 1 + new_pos - resize_gadget.x
    }

    if rl.IsMouseButtonReleased(.LEFT) {
        solve_build_queue()
    }
}