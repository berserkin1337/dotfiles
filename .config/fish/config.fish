if status is-interactive
    # Commands to run in interactive sessions can go here.
end

alias tmux="tmux -u"
alias g++="g++-15"
alias v="nvim"

fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.local/share/bob/nvim-bin"

# Homebrew: supports Apple Silicon macOS and Linuxbrew.
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

set -gx DEV "$HOME/Documents/GitHub"
set -gx EDITOR nvim

# pnpm
if test (uname) = Darwin
    set -gx PNPM_HOME "$HOME/Library/pnpm"
else
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
end
fish_add_path "$PNPM_HOME"

# Java/OpenJDK installed with Homebrew.
fish_add_path /opt/homebrew/opt/openjdk@21/bin

# Bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"

# Coursier
fish_add_path "$HOME/Library/Application Support/Coursier/bin"

# opam
if test -r "$HOME/.opam/opam-init/init.fish"
    source "$HOME/.opam/opam-init/init.fish" > /dev/null 2> /dev/null
end

# Antigravity
fish_add_path "$HOME/.antigravity/antigravity/bin"

# opencode
fish_add_path "$HOME/.opencode/bin"

# LM Studio CLI
fish_add_path "$HOME/.lmstudio/bin"

# Go
fish_add_path "$HOME/go/bin"

# mise
if test -x "$HOME/.local/bin/mise"
    "$HOME/.local/bin/mise" activate fish | source
else if type -q mise
    mise activate fish | source
end
