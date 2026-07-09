# dotfiles

Normal home-relative dotfiles. This repo is **not** in chezmoi format.

## Included

- Fish config: `.config/fish/`
- Fish plugin manifest: `.config/fish/fish_plugins`
- Bun and Copilot fish completions
- tmux config: `.tmux.conf`
- Neovim config: `.config/nvim/init.lua`
- Pi config: `.pi/agent/{AGENTS.md,settings.json,mcp.json,keybindings.json}`

The Pi MCP config is kept cross-platform: `mcp.json` launches a small wrapper script that detects WSL, uses the WSL-specific Chrome bridge there, and falls back to `npx chrome-devtools-mcp@latest` elsewhere.

## Intentionally excluded

- `fish_variables` because it contains machine-specific universal variables and absolute paths
- Old repo contents that used chezmoi-style names such as `dot_config/`

## Install

Back up any existing files first, then copy or symlink the configs:

```sh
mkdir -p ~/.config ~/.pi/agent
cp -R .config/fish ~/.config/
cp -R .config/nvim ~/.config/
cp -R .pi/agent ~/.pi/
cp .tmux.conf ~/.tmux.conf
```

After installing Fish config, restore Fisher plugins from Fish:

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher update
```

Pi note:

- `mcp.json` expects `bash` and `npx` to be available on the host machine.
- On WSL, the wrapper uses the checked-in WSL bridge.
- On Linux, macOS, and non-WSL Windows shells, it falls back to `chrome-devtools-mcp` without hardcoded local paths.

For tmux plugins, install TPM if needed:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then open tmux and press `prefix` + `I` to install plugins.
