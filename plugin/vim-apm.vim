fun! VimApm()
    lua package.loaded["vim-apm"] = nil
    lua package.loaded["vim-apm.buckets"] = nil
    lua package.loaded["vim-apm.utils"] = nil
    lua require("vim-apm").apm()
endfun

fun! VimApmShutdown()
    lua package.loaded["vim-apm"] = nil
    lua package.loaded["vim-apm.buckets"] = nil
    lua package.loaded["vim-apm.utils"] = nil
    lua require("vim-apm").shutdown()
endfun

com! VimApm call VimApm()
com! VimApmShutdown call VimApmShutdown()

"fun! WindowClosed()
"    lua require("vim-apm").on_winclose(<afile>)
"endfun

augroup VimAPM
    autocmd!
    autocmd WinClosed * :lua require("vim-apm").on_winclose(vim.fn.expand('<afile>'))
    autocmd InsertEnter * :lua require("vim-apm").on_insert()
    autocmd InsertLeave * :lua require("vim-apm").on_normal()
    autocmd VimResized * :lua require("vim-apm").on_resize()
augroup END
