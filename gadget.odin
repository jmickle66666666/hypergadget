package main
import rl "vendor:raylib"
import "core:math/rand"

// only serialised data
Gadget :: struct {
    x:int,
    y:int,
    w:int,
    h:int,
    type:GadgetType,
    guid:u32,
}
gadget_list : [dynamic]Gadget

// anything that is cached but not serialised
GadgetCacheData :: struct {
    root : ^Gadget,
    output_type : GadgetOutputType,
    output : rawptr,
    inputs : [dynamic]^Gadget,
}
gadget_cache : map[u32]GadgetCacheData

GadgetOutputType :: enum {
    Nothing,
    String,
}

OutputString :: struct { text:string }

GadgetType :: enum {
    Label,
    Ping,
    Root,
    Chain,

    // string nodes
    Print,
    TextFile,
    ReverseText,
    Text,
}

gadget_type_name :: proc(type:GadgetType) -> string {
    switch type {
        case .Label: return "Label"
        case .Ping: return "Ping"
        case .Root: return "Root"
        case .Chain: return "Chain"
        case .Print: return "Print"
        case .TextFile: return "Text File"
        case .ReverseText: return "Reverse Text"
        case .Text: return "Text"
    }
    return "!NOTHING!"
}

gadget_type_color :: proc(type:GadgetType) -> rl.Color {
    switch type {
        case .Label: return rl.BLUE
        case .Ping: return rl.ORANGE
        case .Root: return rl.WHITE
        case .Chain: return rl.GRAY

        case .Print: return rl.WHITE
        case .TextFile: return rl.PINK
        case .ReverseText: return rl.YELLOW
        case .Text: return rl.PINK
    }
    return rl.GRAY
}

gadget_get_guid :: proc() -> u32 {
    guid :u32= rand.uint32()
    unchecked :bool= true
    for ;unchecked; {
        unchecked = false
        for gadget in gadget_list {
            if gadget.guid == guid {
                guid = rand.uint32()
                unchecked = true
            }
        }
    }
    return guid
}

gadget_create :: proc(x:int, y:int, type:GadgetType) -> ^Gadget {
    guid := gadget_get_guid()
    width := 4
    output_type :GadgetOutputType= .Nothing
    switch type {
        case .Print:
        case .Text:
            map_insert(&config_text_map, guid, (Config_Text){})
            output_type = .String
        case .ReverseText:
            output_type = .String
        case .TextFile:
            map_insert(&config_textfile_map, guid, (Config_TextFile){})
            output_type = .String
        case .Label:
        case .Ping:
            width = 3
        case .Root:
            width = 3
        case .Chain:
            width = 2
    }
    new_gadget :Gadget= {x, y, width, 1, type, guid}
    append(&gadget_list, new_gadget)
    cache_data :GadgetCacheData= {
        &gadget_list[len(gadget_list)-1],
        output_type,
        nil,
        {}
    }
    map_insert(&gadget_cache, new_gadget.guid, cache_data)
    solve_build_queue()
    return &gadget_list[len(gadget_list)-1]
}

gadget_create_at_mouse:: proc(type:GadgetType) {
    ui_menu_clear()
    impos :[2]int= mouse_position()
    gadget_create(impos.x / grid_size, impos.y / grid_size, type)
}

gadget_clean_output_memory :: proc() {
    for &gadget in gadget_list {
        cache := gadget_cache[gadget.guid]

        switch cache.output_type {
            case .Nothing:
            case .String:
                delete((cast(^OutputString)cache.output).text)
                free(cache.output)
        }
    }
}