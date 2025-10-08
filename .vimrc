runtime! debian.vim

syntax on

if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	filetype plugin indent on
endif

set shiftwidth=2
set softtabstop=2
set tabstop=2

set autowrite
set background=dark
set hlsearch
set incsearch
set ignorecase
set nonumber
set autoindent
set smartindent
set copyindent
set ruler
set showcmd
set showmatch
set smartcase

set viminfo='50,<500,s50,h

" disable W11 warning:
autocmd FileChangedShell * :
