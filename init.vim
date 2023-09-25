set ignorecase
set relativenumber
set number
set nohlsearch
set tabstop=4 shiftwidth=4 expandtab
set completeopt=menu,menuone,noselect

let mapleader=" "

"|"""""""""""""""""|
"|     mapping     |
"|"""""""""""""""""|
cnoremap h vert bo help 

map <Leader>sv :source $MYVIMRC<CR>
map <Backspace> <C-6>

nnoremap - vd
nnoremap <Leader>e "+yy
nnoremap x "xx
nnoremap <Leader>r "+p
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <C-n> <CMD>NvimTreeToggle<CR>
" nmap f <Leader><Leader>f
" nmap F <Leader><Leader>F

" vmap f <Leader><Leader>f
" vmap F <Leader><Leader>F

imap jk <Esc>
imap <C-n> :Explore<CR>

vnoremap x "xx
vnoremap <Leader>e "+y
vnoremap <Leader>r "+p

lua << EOF
    require("init")
EOF

""""""""""""""""""""""""""""""""""""""""""
" setting up plugin with pure vim script "
""""""""""""""""""""""""""""""""""""""""""
let g:EasyMotion_smartcase = 1
