package main
import "core:fmt"
import "core:slice"

solve_queue :[dynamic]^Gadget

solve_traverse :: proc() {


    for len(solve_queue) > 0 {
        queue_index := len(solve_queue)-1
        solve_process_gadget(solve_queue[queue_index])
        ordered_remove(&solve_queue, queue_index)
    }

    gadget_clean_output_memory()

    // we build the queue after any action that would change it
    // so it should be already built before we run the solver
    // meaning we can skip doing it beforehand, then repopulate it after
    solve_build_queue()
}

solve_build_queue :: proc() {
    clear(&solve_queue)
    
    roots := solve_find_gadgets_of_type(.Root)
    defer delete(roots)
    for root in roots {
        append(&solve_queue, root)
    }

    for i:=0; i < len(solve_queue); i += 1 {
        solve_traverse_gadget(i)
    }
}

solve_traverse_gadget :: proc(queue_index:int) {

    solve_do_input_count :: proc(gadget:^Gadget, count:int) {
        inputs := solve_find_inputs(gadget)
        defer delete(inputs)

        cache := &gadget_cache[gadget.guid]
        clear(&cache.inputs)

        c := 0
        for input in inputs {
            append(&cache.inputs, input)
            append(&solve_queue, input)
            c += 1
            if c >= count { break }
        }
    }

    gadget := solve_queue[queue_index]
    switch gadget.type {
        case .Label:
        case .Ping:
        case .Root:
            solve_do_input_count(gadget, 9999)
        case .Chain:
            solve_do_input_count(gadget, 1)
        case .Print:
            solve_do_input_count(gadget, 1)
        case .ReverseText:
            solve_do_input_count(gadget, 1)
        case .TextFile: 
    }
}

solve_process_gadget :: proc(gadget:^Gadget) {
    switch gadget.type {
        // gadgets that dont do anything
        case .Chain:
        case .Root:
        case .Label:

        // gadgets that do something
        case .Ping:
            process_ping()

        case .Print:
            process_print(gadget)
        case .ReverseText:
            process_reversetext(gadget)
        case .TextFile:
            process_textfile(gadget)
    }
}

solve_find_gadgets_of_type :: proc(type:GadgetType) -> [dynamic]^Gadget {
    output :[dynamic]^Gadget= {}
    for &gadget in gadget_list {
        if gadget.type == type {
            append(&output, &gadget)
        }
    }
    return output
}

solve_find_gadget_at :: proc(x:int, y:int) -> ^Gadget {
    for &gadget in gadget_list {
        if gadget.y == y && x >= gadget.x && x < gadget.x + gadget.w {
            return &gadget
        }
    }
    return nil
}

solve_queue_contains :: proc(gadget: ^Gadget) -> bool {
    for queue_gadget in solve_queue {
        if gadget == queue_gadget {
            return true
        }
    }
    return false
}

solve_find_inputs :: proc(gadget: ^Gadget) -> [dynamic]^Gadget {
    output :[dynamic]^Gadget = {}

    for i:=gadget.x; i < gadget.x + gadget.w; i+=1 {
        found_gadget := solve_find_gadget_at(i, gadget.y - 1)
        if found_gadget != nil && !slice.contains(output[:], found_gadget) {
            append(&output, found_gadget)
        }
    }
    return output
}