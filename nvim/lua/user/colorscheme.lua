vim.cmd [[
try
  let g:tokyonight_style = "night"
  colorscheme catppuccin
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]
