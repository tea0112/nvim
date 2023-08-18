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
map <Leader>sv :source $MYVIMRC<CR>
map <Backspace> <C-6>
map <Leader>e "+yy
nnoremap <Leader>r "+p

" Find files using Telescope command-line sugar.
nnoremap ;a <CMD>Telescope find_files<CR>
nnoremap ;s <CMD>Telescope live_grep<CR>
nnoremap ;d <CMD>Telescope buffers<CR>
nnoremap ;f <CMD>Telescope help_tags<CR>
nnoremap <C-n> <CMD>NvimTreeToggle<CR>
nmap f <Leader><Leader>f
nmap F <Leader><Leader>F
vmap f <Leader><Leader>f
vmap F <Leader><Leader>F

imap jk <Esc>
imap <C-n> :Explore<CR>

vnoremap <Leader>e "+y
vnoremap <Leader>r "+p

lua << EOF
    require("init")
EOF
