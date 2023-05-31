set ignorecase
set relativenumber
set number
set nohlsearch
set tabstop=4 shiftwidth=4 expandtab

let mapleader=" "

"""""""""""""""""""
" normal mode map "
"""""""""""""""""""
map <leader>sv :source $MYVIMRC<CR>

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <CMD>Telescope find_files<CR>
nnoremap <leader>fg <CMD>Telescope live_grep<CR>
nnoremap <leader>fb <CMD>Telescope buffers<CR>
nnoremap <leader>fh <CMD>Telescope help_tags<CR>
nnoremap <C-n> <CMD>NvimTreeToggle<CR>

imap jk <Esc>
imap <C-n> :Explore<CR>

lua << EOF
    require("init")
EOF
