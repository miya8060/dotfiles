function peco-src
    set selected_dir (ghq list -p | peco --query (commandline -b))
    if test -n "$selected_dir"
        commandline "cd $selected_dir"
        commandline -f execute
    end
    commandline -f repaint
end
