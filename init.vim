set ignorecase
set relativenumber
set number
set nohlsearch
set tabstop=4 shiftwidth=4 expandtab
set completeopt=menu,menuone,noselect

let mapleader=" "

"""""""""""""""""""
" normal mode map "
"""""""""""""""""""
map <leader>sv :source $MYVIMRC<CR>
map <Backspace> <C-6>

" Find files using Telescope command-line sugar.
nnoremap ;a <CMD>Telescope find_files<CR>
nnoremap ;s <CMD>Telescope live_grep<CR>
nnoremap ;d <CMD>Telescope buffers<CR>
nnoremap ;f <CMD>Telescope help_tags<CR>
nnoremap <C-n> <CMD>NvimTreeToggle<CR>

imap jk <Esc>
imap <C-n> :Explore<CR>

lua << EOF
    require("init")
EOF
