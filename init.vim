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
" nnoremap <C-n> <CMD>NvimTreeToggle<CR>

imap jk <Esc>
imap <C-n> :Explore<CR>

vnoremap x "xx
vnoremap <Leader>e "+y
vnoremap <Leader>r "+p

" Map gj gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" map fast tab index
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>

lua << EOF
    require("init")
EOF

""""""""""""""""""""""""""""""""""""""""""
" setting up plugin with pure vim script "
""""""""""""""""""""""""""""""""""""""""""
let g:EasyMotion_smartcase = 1
