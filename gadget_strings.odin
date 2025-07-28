package main
import "core:fmt"
import "core:strings"
import "core:os"

// print
process_print :: proc(gadget:^Gadget) {
    cache:=&gadget_cache[gadget.guid]
    input_cache := &gadget_cache[cache.inputs[0].guid]
    data :^OutputString= cast(^OutputString)input_cache.output
    fmt.println(data.text)
}

// textfile
Config_TextFile :: struct {
    path: string
}
config_textfile_map :map[u32]Config_TextFile

process_textfile :: proc(gadget:^Gadget) {
    // just do a test thing for now
    read, success := os.read_entire_file_from_filename("test.txt")

    cache:=&gadget_cache[gadget.guid]
    output := new(OutputString)
    output.text = string(read)
    cache.output = output
}

// reverse text
process_reversetext :: proc(gadget:^Gadget) {
    cache:=&gadget_cache[gadget.guid]
    input_cache := &gadget_cache[cache.inputs[0].guid]
    data :^OutputString= cast(^OutputString)input_cache.output
    output := new(OutputString)
    output.text = strings.reverse(data.text)
    cache.output = output

    // TODO: memory
}

// text
Config_Text :: struct {
    text: string
}
config_text_map :map[u32]Config_Text

process_text :: proc(gadget:^Gadget) {
    config := config_text_map[gadget.guid]
    cache:=&gadget_cache[gadget.guid]
    output := new(OutputString)
    output.text = string(config.text)
    cache.output = output
}