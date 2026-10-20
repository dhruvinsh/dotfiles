# Run a command and pipe its output into fzf: `f <cmd…> -- <fzf args…>`
function f --description 'Pipe a command into fzf (args after -- go to fzf)'
    set -l cmd
    set -l fzf_args
    set -l found_sep 0
    for arg in $argv
        if test "$arg" = --
            set found_sep 1
            continue
        end
        if test $found_sep -eq 0
            set -a cmd $arg
        else
            set -a fzf_args $arg
        end
    end
    $cmd | fzf $fzf_args
end
