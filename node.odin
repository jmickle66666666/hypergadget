package main
import rl "vendor:raylib"

Gadget :: struct {
    x:int,
    y:int,
    w:int,
    h:int,
    type:GadgetType,
}

GadgetOutputType :: enum {
    Nothing,
    String,
}

GadgetType :: enum {
    Label,
    Ping,
    Conclusion,
    Chain,
}

gadget_type_name :: proc(type:GadgetType) -> string {
    switch type {
        case .Label: return "Label"
        case .Ping: return "Ping"
        case .Conclusion: return "Conclusion"
        case .Chain: return "Chain"
    }
    return "!NOTHING!"
}

gadget_type_color :: proc(type:GadgetType) -> rl.Color {
    switch type {
        case .Label: return rl.BLUE
        case .Ping: return rl.ORANGE
        case .Conclusion: return rl.WHITE
        case .Chain: return rl.GRAY
    }
    return rl.GRAY
}