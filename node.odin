package main
import rl "vendor:raylib"

Node :: struct {
    x:int,
    y:int,
    w:int,
    h:int,
    // color:rl.Color,
    type:NodeType,
}

NodeType :: enum {
    Label,
    Ping,
    Conclusion,
}

node_type_name :: proc(type:NodeType) -> string {
    switch type {
        case .Label: return "Label"
        case .Ping: return "Ping"
        case .Conclusion: return "Conclusion"
    }
    return "!NOTHING!"
}

node_type_color :: proc(type:NodeType) -> rl.Color {
    switch type {
        case .Label: return rl.BLUE
        case .Ping: return rl.ORANGE
        case .Conclusion: return rl.WHITE
    }
    return rl.GRAY
}