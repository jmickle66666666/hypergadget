package settings
import "core:os"
import "core:io"
import "core:fmt"
import "core:strconv"
import "core:reflect"
import "core:strings"
import rl "vendor:raylib"

// TO ADD A NEW SETTING, PUT IT HERE, AND ALSO IN THE init PROC FURTHER DOWN. THANKS
Settings :: struct {
    window_x:int,
    window_y:int,
}
cfg : Settings

SETTINGS_PATH :: "settings.txt"
init :: proc() {
    if os.exists(SETTINGS_PATH) {
        data, _ := os.read_entire_file_from_filename(SETTINGS_PATH, context.allocator)
        text := transmute(string)data
        lines := strings.split(text, "\n")
        for line in lines {
            tokens := strings.split(line, " ")
            if len(tokens) != 2 { continue }
            value := strings.trim_space(tokens[1])
            
            switch tokens[0] {
                case "window_x": cfg.window_x, _ = strconv.parse_int(value)
                case "window_y": cfg.window_y, _ = strconv.parse_int(value)
            }

            fmt.println(tokens[0])
        }
    } else {
        // SET ALL DEFAULTS HERE
        cfg.window_x = 10
        cfg.window_y = 10

        save()
    }
}

save :: proc() {
    if os.exists(SETTINGS_PATH) {
        os.remove(SETTINGS_PATH)
    }

    

    // handle, _ := os.open(SETTINGS_PATH, os.O_CREATE, ODIN_OS == .Linux?0o777:0)
    // file_stream := os.stream_from_handle(handle)
    string_builder := strings.builder_make()

    struct_field_count := reflect.struct_field_count(Settings)

    for i:=0; i<struct_field_count; i+=1 {
        field := reflect.struct_field_at(Settings, i)
        strings.write_string(&string_builder, field.name)
        strings.write_string(&string_builder, " ")
        
        switch field.type {
            case type_info_of(f32): strings.write_f32(&string_builder, reflect.struct_field_value(cfg, field).(f32), 'f')
            case type_info_of(int): strings.write_int(&string_builder, reflect.struct_field_value(cfg, field).(int))
            case type_info_of(bool): strings.write_string(&string_builder, reflect.struct_field_value(cfg, field).(bool)?"true":"false")
        }
        strings.write_string(&string_builder, "\n")
    }

    output := strings.to_string(string_builder)

    // io.close(file_stream)
    // os.close(handle)
    rl.SaveFileText(SETTINGS_PATH, raw_data(output))
}