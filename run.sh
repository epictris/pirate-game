#!/usr/bin/env bash

term_exec="alacritty"
nvim_exec="nvim"
server_path="/tmp/godot.pipe"

server_startup_delay=0.1 # in seconds

start_server() {
    "$term_exec" -e "$nvim_exec" --listen "$server_path"
}

open_file_in_server() {
    # - escape stuff because nvim will not
    filename=$(printf %q "$1")
    "$term_exec" -e "$nvim_exec" --server "$server_path" --remote-send "<C-\><C-n>:n $filename<CR>:call cursor($2)<CR>"
}

if ! [ -e "$server_path" ]; then
    # - start server FIRST then open the file
    start_server &
    sleep $server_startup_delay # - wait for the server to start 
    open_file_in_server "$1" "$2"
else
    open_file_in_server "$1" "$2"
fi
