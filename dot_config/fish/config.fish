if status is-interactive
    # Commands to run in interactive sessions can go here
end
alias tmux="tmux -u"
alias v="nvim"
fish_add_path ~/.local/bin/
fish_add_path ~/.cargo/bin/
fish_add_path ~/.local/share/bob/nvim-bin
set -gx EDITOR nvim
# pnpm
set -gx PNPM_HOME "/home/aviral/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
