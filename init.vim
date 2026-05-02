let g:neovide_scale_factor = 1.5
set ignorecase
set relativenumber
set number
set tabstop=4 shiftwidth=4 expandtab softtabstop=4
set completeopt=menu,menuone,noselect
" set nohlsearch

let mapleader=" "

"|"""""""""""""""""|
"|     mapping     |
"|"""""""""""""""""|
" Mappings are set in lua/init.lua so each one can have a description.

lua << EOF
    require("init")
EOF

""""""""""""""""""""""""""""""""""""""""""
" setting up plugin with pure vim script "
""""""""""""""""""""""""""""""""""""""""""
let g:EasyMotion_smartcase = 1
