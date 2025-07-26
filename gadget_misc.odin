package main

//ping
process_ping :: proc() {
    toast("Ping!")
}

process_chain :: proc(gadget : ^Gadget) {
    cache := &gadget_cache[gadget.guid]
    cache.output = gadget_cache[cache.inputs[0].guid].output
}