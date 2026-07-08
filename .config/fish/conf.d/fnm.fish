# fnm
set -l fnm_paths "$HOME/Library/Application Support/fnm" "$HOME/.local/share/fnm"
for fnm_path in $fnm_paths
    if test -d "$fnm_path"
        fish_add_path "$fnm_path"
    end
end

if type -q fnm
    fnm env --use-on-cd | source
end
