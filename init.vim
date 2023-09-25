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
map <Leader>sv :source $MYVIMRC<CR>
map <Backspace> <C-6>

nnoremap ,h :vert bo help 
nnoremap <A-h> <c-w>h
nnoremap <A-j> <c-w>j
nnoremap <A-k> <c-w>k
nnoremap <A-l> <c-w>l
nnoremap - vd
nnoremap <Leader>e "+yy
nnoremap x "xx
nnoremap <Leader>r "+p
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <C-n> <CMD>NvimTreeToggle<CR>

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
