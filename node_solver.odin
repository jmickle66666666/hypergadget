package main
import "core:fmt"
import "core:slice"

solve_queue :[dynamic]^Node

solve_traverse :: proc() {
    // step 1: find the conclusion node
    // step 2: find the input node(s) for it
    // step 3: add them all to a list/queue
    // step 4: solve the newest added node on the queue
    // step 5: which means do step 2 on it

    clear(&solve_queue)
    conclusions := solve_find_nodes_of_type(.Conclusion)
    defer delete(conclusions)
    for conclusion in conclusions {
        append(&solve_queue, conclusion)
    }

    for len(solve_queue) > 0 {
        solve_node(len(solve_queue)-1)
    }
}

solve_find_nodes_of_type :: proc(type:NodeType) -> [dynamic]^Node {
    output :[dynamic]^Node= {}
    for &node in node_list {
        if node.type == type {
            append(&output, &node)
        }
    }
    return output
}

solve_node :: proc(queue_index:int) {
    node := solve_queue[queue_index]
    // fmt.println("Solving", node_type_name(node.type), node.x, node.y)
    switch node.type {
        case .Label:
            // doesn't do anything
        case .Ping:
            toast("Ping!")
            // fmt.println("Ping!", node.x, node.y)
        case .Conclusion:
            inputs := solve_find_inputs(node)
            defer delete(inputs)

            for input in inputs {
                append(&solve_queue, input)
                // fmt.println("Appending", input)
            }
    }
    ordered_remove(&solve_queue, queue_index)
}

solve_find_node_at :: proc(x:int, y:int) -> ^Node {
    for &node in node_list {
        if node.y == y && x >= node.x && x < node.x + node.w {
            return &node
        }
    }
    return nil
}

solve_queue_contains :: proc(node: ^Node) -> bool {
    for queue_node in solve_queue {
        if node == queue_node {
            return true
        }
    }
    return false
}

solve_find_inputs :: proc(node: ^Node) -> [dynamic]^Node {
    output :[dynamic]^Node = {}

    for i:=node.x; i < node.x + node.w; i+=1 {
        found_node := solve_find_node_at(i, node.y - 1)
        if found_node != nil && !slice.contains(output[:], found_node) {
            append(&output, found_node)
        }
    }
    return output
}