-- This is where your custom modules and plugins go.
-- See the wiki for a guide on how to extend NvChad

local hooks = require "core.hooks"

-- NOTE: To use this, make a copy with `cp example_init.lua init.lua`

--------------------------------------------------------------------

-- To modify packaged plugin configs, use the overrides functionality
-- if the override does not exist in the plugin config, make or request a PR,
-- or you can override the whole plugin config with 'chadrc' -> M.plugins.default_plugin_config_replace{}
-- this will run your config instead of the NvChad config for the given plugin

-- hooks.override("lsp", "publish_diagnostics", function(current)
--   current.virtual_text = false;
--   return current;
-- end)

-- To add new mappings, use the "setup_mappings" hook,
-- you can set one or many mappings
-- example below:

hooks.add("setup_mappings", function(map)
   map("n", "<leader>cc", "gg0vG$d", opt) -- example to delete the buffer
   map("n","<leader>fg","<cmd>Telescope live_grep<cr>",opt)
   map("n","<leader>fh","<cmd>Telescope help_tags<cr>",opt)
   map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
   map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
   map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
   map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
   map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
   map('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
   map('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
   map('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
   map('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
   map('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
   map('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
   map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
   map('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
   map('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
   map('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
   map('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
   map('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end)

-- To add new plugins, use the "install_plugin" hook,
-- NOTE: we heavily suggest using Packer's lazy loading (with the 'event' field)
-- see: https://github.com/wbthomason/packer.nvim
-- examples below:

hooks.add("install_plugins", function(use)
  use {
     'morhetz/gruvbox'
  }
 use {
      "williamboman/nvim-lsp-installer",
      config = function()
         local lsp_installer = require "nvim-lsp-installer"

         lsp_installer.on_server_ready(function(server)
            local opts = {}

            server:setup(opts)
            vim.cmd [[ do User LspAttachBuffers ]]
         end)
      end,
   }
    use {
      "jose-elias-alvarez/null-ls.nvim",
      after = "nvim-lspconfig",
      config = function()
         require("custom.plugin_confs.null-ls").setup()
      end,
   }

-- load it after nvim-lspconfig , since we'll use some lspconfig stuff in the null-ls config!
end)

-- alternatively, put this in a sub-folder like "lua/custom/plugins/mkdir"
-- then source it with

-- require "custom.plugins.mkdir"
