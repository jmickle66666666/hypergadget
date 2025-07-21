package main
import "core:fmt"
import "core:slice"

solve_queue :[dynamic]^Gadget

solve_traverse :: proc() {
    // step 1: find the conclusion gadget
    // step 2: find the input gadget(s) for it
    // step 3: add them all to a list/queue
    // step 4: solve the newest added gadget on the queue
    // step 5: which means do step 2 on it

    for len(solve_queue) > 0 {
        queue_index := len(solve_queue)-1
        solve_process_gadget(solve_queue[queue_index])
        ordered_remove(&solve_queue, queue_index)
    }

    // we build the queue after any action that would change it
    // so it should be already built before we run the solver
    // meaning we can skip doing it beforehand, then repopulate it after
    solve_build_queue()
}

solve_build_queue :: proc() {
    clear(&solve_queue)
    conclusions := solve_find_gadgets_of_type(.Conclusion)
    defer delete(conclusions)
    for conclusion in conclusions {
        append(&solve_queue, conclusion)
    }

    for i:=0; i < len(solve_queue); i += 1 {
        solve_traverse_gadget(i)
    }
}

solve_traverse_gadget :: proc(queue_index:int) {
    gadget := solve_queue[queue_index]
    switch gadget.type {
        case .Label:
        case .Ping:
        case .Conclusion:
            inputs := solve_find_inputs(gadget)
            defer delete(inputs)

            for input in inputs {
                append(&solve_queue, input)
            }
        case .Chain:
            inputs := solve_find_inputs(gadget)
            defer delete(inputs)

            for input in inputs {
                append(&solve_queue, input)
            }
    }
}

solve_process_gadget :: proc(gadget:^Gadget) {
    switch gadget.type {
        // gadgets that dont do anything
        case .Chain:
        case .Conclusion:
        case .Label:

        // gadgets that do something
        case .Ping:
            toast("Ping!")
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