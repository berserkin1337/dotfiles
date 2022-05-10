vim.cmd [[
try
  set background=dark
  colorscheme base16-onedark
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]
