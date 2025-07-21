package main

import "core:mem"
import "core:fmt"
import rl "vendor:raylib"


debug_show_allocated_string : [128]u8
tracking_allocator : mem.Tracking_Allocator

debug_toggle_help : bool = false
debug_toggle_print_memory : bool = false
debug_toggle_draw_memory_graph : bool = false
debug_toggle_draw_updatetime_graph : bool = false
debug_memory_graph_update_length : int = 8
debug_draw_quadtree : bool = false

debug_minimum_memory : i64 = 0

debug_memory_graph_data : [SCREEN_WIDTH]i64
debug_update_graph_data : [SCREEN_HEIGHT]f64

debug_init :: proc()
{
    // if DEBUG_MODE == false { return }
}

debug_update :: proc()
{
    if DEBUG_MODE == false { return }

    if debug_minimum_memory == 0 {
        debug_minimum_memory = tracking_allocator.current_memory_allocated
    }

    if rl.IsKeyPressed(.F1) { debug_toggle_help =! debug_toggle_help }
    if rl.IsKeyPressed(.F2) { debug_toggle_print_memory =! debug_toggle_print_memory }
    if rl.IsKeyPressed(.F3) { debug_toggle_draw_memory_graph =! debug_toggle_draw_memory_graph }
    if rl.IsKeyPressed(.F4) { if debug_memory_graph_update_length > 1 { debug_memory_graph_update_length /= 2 } }
    if rl.IsKeyPressed(.F5) { debug_memory_graph_update_length *= 2 }
    if rl.IsKeyPressed(.F6) { debug_draw_quadtree = !debug_draw_quadtree }
    if rl.IsKeyPressed(.F7) { debug_toggle_draw_updatetime_graph = !debug_toggle_draw_updatetime_graph }

    if time % debug_memory_graph_update_length == 0 {
        for i:=0; i < len(debug_memory_graph_data)-1; i+=1 {
            debug_memory_graph_data[i] = debug_memory_graph_data[i+1]
        }
        debug_memory_graph_data[len(debug_memory_graph_data)-1] = tracking_allocator.current_memory_allocated
    }
}

debug_add_frame_time :: proc(time: f64)
{
    for i:=0; i < len(debug_update_graph_data)-1; i+=1 {
        debug_update_graph_data[i] = debug_update_graph_data[i+1]
    }
    debug_update_graph_data[len(debug_update_graph_data)-1] = time
}

debug_draw :: proc()
{
    if DEBUG_MODE == false { return }

    if time < 120 { draw_text("f1: debug hotkeys", 2, 16, rl.WHITE) }
    if debug_toggle_help {
        y :i32= 16 + i32(font_size)
        draw_text("f2: print memory", 2, y, rl.WHITE); y+= i32(font_size)
        draw_text("f3: memory graph", 2, y, rl.WHITE); y+= i32(font_size)
        draw_text("f4: faster memory", 2, y, rl.WHITE); y+= i32(font_size)
        draw_text("f5: slower memory", 2, y, rl.WHITE); y+= i32(font_size)
        draw_text("f6: draw quadtree", 2, y, rl.WHITE); y+= i32(font_size)
        draw_text("f7: update time graph", 2, y, rl.WHITE); y+= i32(font_size)
    }

    if debug_toggle_print_memory {
        fmt.bprint(debug_show_allocated_string[:], "memory allocated:", tracking_allocator.current_memory_allocated)
        draw_text(string(debug_show_allocated_string[:]), 2, 4, rl.WHITE)
    }

    if debug_toggle_draw_memory_graph {
        max_val :i64= 1
        for i:=0; i < len(debug_memory_graph_data); i+=1 {
            if debug_memory_graph_data[i] > max_val {
                max_val = debug_memory_graph_data[i]
            }
        }
        scale :f32= f32(SCREEN_HEIGHT) / f32(max_val)

        rl.DrawLine(0, SCREEN_HEIGHT - i32(f32(debug_minimum_memory) * scale), SCREEN_WIDTH, SCREEN_HEIGHT - i32(f32(debug_minimum_memory) * scale), rl.BLUE)

        for i:=0; i < len(debug_memory_graph_data)-1; i+=1 {
            y0 := SCREEN_HEIGHT - f32(debug_memory_graph_data[i]) * scale
            y1 := SCREEN_HEIGHT - f32(debug_memory_graph_data[i+1]) * scale
            col := rl.GREEN
            if debug_memory_graph_data[i] < debug_memory_graph_data[i+1] { col = rl.RED }
            if debug_memory_graph_data[i] > debug_memory_graph_data[i+1] { col = rl.YELLOW }
            rl.DrawLine(i32(i), i32(y0), i32(i+1), i32(y1), col)
        }
    }

    if debug_toggle_draw_updatetime_graph {
        scale :f32 = 100000.0

        for i:=0; i < len(debug_update_graph_data)-1; i+=1 {
            y0 := f32(debug_update_graph_data[i]) * scale
            rl.DrawLine(i32(i), i32(SCREEN_HEIGHT - y0), i32(i), SCREEN_HEIGHT, rl.ORANGE)
        }

        // draw line at 1ms
        msY := SCREEN_HEIGHT - 0.001 * scale
        draw_text("1ms", 2, SCREEN_HEIGHT - i32(msY - 2), rl.BLUE)
        rl.DrawLine(0, SCREEN_HEIGHT - i32(msY), SCREEN_WIDTH, SCREEN_HEIGHT - i32(msY), rl.BLUE)
    }
}
