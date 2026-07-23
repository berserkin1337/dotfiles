-- Modern cross-platform Neovim IDE config.
-- Plugin choices were checked for non-archived repos with recent activity (2026-07-08).

local fn = vim.fn
local is_windows = vim.loop.os_uname().sysname:match("Windows") ~= nil or fn.has("win32") == 1 or fn.has("win64") == 1
local is_wsl = fn.has("wsl") == 1 or (vim.env.WSL_DISTRO_NAME ~= nil)
local home = fn.expand("~")

-- Cross-platform clipboard. WSL uses the Windows clipboard; other platforms use Neovim defaults.
if is_wsl and fn.executable("clip.exe") == 1 and fn.executable("powershell.exe") == 1 then
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
    paste = {
      ["+"] = { "powershell.exe", "-NoLogo", "-NoProfile", "-Command", [[Get-Clipboard -Raw | % { $input = $_; [Console]::Out.Write($input -replace "`r", "") }]] },
      ["*"] = { "powershell.exe", "-NoLogo", "-NoProfile", "-Command", [[Get-Clipboard -Raw | % { $input = $_; [Console]::Out.Write($input -replace "`r", "") }]] },
    },
    cache_enabled = 0,
  }
end
vim.opt.clipboard = "unnamedplus"

-- Core editor settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 200
vim.opt.timeoutlen = 400
vim.opt.undofile = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.completeopt = { "menu", "menuone", "noinsert", "popup" }
vim.opt.shortmess:append("c")

-- Make Mason binaries visible to Neovim-managed tools on Linux/macOS/Windows.
local mason_bin = fn.stdpath("data") .. "/mason/bin"
local path_sep = is_windows and ";" or ":"
if not string.find(vim.env.PATH or "", mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. path_sep .. (vim.env.PATH or "")
end

-- Bootstrap lazy.nvim
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazy_repo = "https://github.com/folke/lazy.nvim.git"
  local out = fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazy_repo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Theme / UI
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false,
        transparent = false,
        theme = "wave",
        background = { dark = "wave", light = "lotus" },
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.icons").setup()
      require("mini.comment").setup()
      require("mini.pairs").setup()
      require("mini.surround").setup({
        mappings = {
          add = "ys",
          delete = "ds",
          find = "",
          find_left = "",
          highlight = "",
          replace = "cs",
          suffix_last = "",
          suffix_next = "",
        },
        search_method = "cover_or_next",
      })

      -- Match vim-surround's visual and whole-line mappings.
      vim.keymap.del("x", "ys")
      vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add("visual")<CR>]], { silent = true })
      vim.keymap.set("n", "yss", "ys_", { remap = true })
      require("mini.ai").setup()
      require("mini.indentscope").setup({ symbol = "│" })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "echasnovski/mini.nvim" },
    config = function()
      require("lualine").setup({
        options = { theme = "kanagawa", globalstatus = true, component_separators = "", section_separators = { left = "", right = "" } },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "romus204/tree-sitter-manager.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("tree-sitter-manager").setup({
        ensure_installed = {
          "svelte",
          "html",
          "css",
          "javascript",
          "typescript",
          "tsx",
          "json",
          "lua",
          "rust",
          "go",
          "bash",
          "markdown",
          "markdown_inline",
        },
        auto_install = true,
        highlight = true,
        border = "rounded",
      })
    end,
  },

  -- Navigation / files / git
  {
    "ibhagwan/fzf-lua",
    dependencies = { "echasnovski/mini.nvim" },
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
    },
    opts = { "max-perf", winopts = { preview = { default = "bat" } } },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "Toggle file tree" },
      { "<leader>E", "<cmd>Neotree focus<cr>", desc = "Focus file tree" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      filesystem = {
        follow_current_file = { enabled = true },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        position = "left",
        width = 32,
      },
    },
  },
  {
    "stevearc/oil.nvim",
    keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory" } },
    opts = { default_file_explorer = false, view_options = { show_hidden = true } },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- LSP / completion / diagnostics
  { "neovim/nvim-lspconfig" },
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      PATH = "prepend",
      ui = { border = "rounded" },
    },
  },
  { "mason-org/mason-lspconfig.nvim" },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { auto_show = true },
        list = { selection = { preselect = false, auto_insert = false } },
      },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
    },
  },
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "javascript" or ft == "typescript" or ft == "javascriptreact" or ft == "typescriptreact" or ft == "svelte" or ft == "json" or ft == "jsonc" or ft == "css" or ft == "html" or ft == "markdown" then
          return { timeout_ms = 2000, lsp_fallback = true }
        end
        return { timeout_ms = 2000, lsp_fallback = true }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        rust = { "rustfmt" },
        go = { "goimports", "gofmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      modes = {
        diagnostics = {
          -- Keep external dependencies and the Go standard library out of the list.
          filter = function(items)
            local cwd = (vim.uv or vim.loop).cwd()
            return vim.tbl_filter(function(item)
              return item.filename and vim.fs.relpath(cwd, item.filename) ~= nil
            end, items)
          end,
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
    },
  },

  -- Rust: active replacement for archived rust-tools.nvim.
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { "rust" },
  },

  -- Debugging
  { "nvim-neotest/nvim-nio" },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "leoluz/nvim-dap-go",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP step out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "DAP REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "DAP UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      require("dapui").setup()
      require("nvim-dap-virtual-text").setup()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      local mason_path = fn.stdpath("data") .. "/mason"
      local js_debug_path = mason_path .. "/packages/js-debug-adapter"
      local js_debug_bin = js_debug_path .. "/js-debug/src/dapDebugServer.js"
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_bin, "${port}" },
        },
      }
      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact", "svelte" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch current file (Node.js)",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch current file (Bun)",
            runtimeExecutable = "bun",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            console = "integratedTerminal",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node/Bun process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
          },
        }
      end

      local codelldb = mason_path .. "/packages/codelldb/extension/adapter/codelldb"
      if is_windows then codelldb = codelldb .. ".exe" end
      dap.adapters.codelldb = { type = "server", port = "${port}", executable = { command = codelldb, args = { "--port", "${port}" } } }
      dap.configurations.rust = {
        {
          name = "Launch Rust binary",
          type = "codelldb",
          request = "launch",
          program = function()
            return fn.input("Path to executable: ", fn.getcwd() .. (is_windows and "\\target\\debug\\" or "/target/debug/"), "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      require("dap-go").setup({
        delve = {
          path = is_windows and "dlv.exe" or "dlv",
        },
      })
    end,
  },
}, {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})

-- Native Tree-sitter highlighting for Neovim 0.12+.
-- nvim-treesitter is intentionally not used because its original repository is archived.
-- tree-sitter-manager.nvim installs parsers and queries, including Svelte, then uses native highlighting.

-- Diagnostics UI
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

map("n", "<leader>w", "<cmd>w<cr>", "Save")
map("n", "<leader>q", "<cmd>q<cr>", "Quit")
map("n", "<leader>o", "<cmd>Oil<cr>", "Open Oil file editor")
map("n", "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, "Format")

-- LSP configuration
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

local function on_attach(_, bufnr)
  local function bmap(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
  end
  bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
  bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  bmap("n", "gr", vim.lsp.buf.references, "References")
  bmap("n", "gi", vim.lsp.buf.implementation, "Implementation")
  bmap("n", "K", vim.lsp.buf.hover, "Hover")
  bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  bmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
  bmap("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
  bmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
end

local servers = {
  vtsls = {
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    settings = {
      typescript = { inlayHints = { parameterNames = { enabled = "literals" }, variableTypes = { enabled = true }, propertyDeclarationTypes = { enabled = true }, functionLikeReturnTypes = { enabled = true } } },
      javascript = { inlayHints = { parameterNames = { enabled = "literals" }, variableTypes = { enabled = true }, propertyDeclarationTypes = { enabled = true }, functionLikeReturnTypes = { enabled = true } } },
    },
  },
  svelte = {},
  eslint = {},
  gopls = {
    settings = { gopls = { gofumpt = true, staticcheck = true, usePlaceholders = true, hints = { assignVariableTypes = true, compositeLiteralFields = true, constantValues = true, functionTypeParameters = true, parameterNames = true, rangeVariableTypes = true } } },
  },
  lua_ls = {
    settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false }, telemetry = { enable = false } } },
  },
  jsonls = {
    settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
  },
  html = {},
  cssls = {},
}

require("mason").setup()
local ensure_lsp = vim.tbl_keys(servers)
table.insert(ensure_lsp, "rust_analyzer")
require("mason-lspconfig").setup({
  ensure_installed = ensure_lsp,
  automatic_enable = false,
})
require("mason-tool-installer").setup({
  ensure_installed = {
    "vtsls",
    "svelte-language-server",
    "eslint-lsp",
    "rust-analyzer",
    "gopls",
    "lua-language-server",
    "json-lsp",
    "html-lsp",
    "css-lsp",
    "prettier",
    "eslint_d",
    "stylua",
    "goimports",
    "gofumpt",
    "delve",
    "codelldb",
    "js-debug-adapter",
    "tree-sitter-cli",
  },
  auto_update = false,
  run_on_start = true,
  start_delay = 3000,
})

for server, config in pairs(servers) do
  config.capabilities = capabilities
  config.on_attach = on_attach
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

-- rustaceanvim reads this automatically. It augments rust-analyzer and can use codelldb.
vim.g.rustaceanvim = {
  server = { capabilities = capabilities, on_attach = on_attach },
}
