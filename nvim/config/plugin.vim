" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

Plug 'vim-scripts/BufOnly.vim'

" Color themes
Plug 'dracula/vim'

" Fuzzy search
Plug 'ctrlpvim/ctrlp.vim'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Vim Tmux Navigation
Plug 'christoomey/vim-tmux-navigator'

" Code formatting
Plug 'sbdchd/neoformat'

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Support for UNIX shell commands
Plug 'tpope/vim-eunuch'

" Markdown support
Plug 'godlygeek/tabular', { 'for': 'markdown' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" Auto colose and surround
Plug 'jiangmiao/auto-pairs'

" Easy uncomment/comment
Plug 'terrortylor/nvim-comment'

" Python support
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }

" CSV support
Plug 'chrisbra/csv.vim', { 'for': 'csv' }

" GO Support
Plug 'fatih/vim-go', { 'for': 'go' }

" Silver searcher support
Plug 'rking/ag.vim'

" Easymotion
Plug 'easymotion/vim-easymotion'

" Easy align
Plug 'junegunn/vim-easy-align'

" Git support
Plug 'tpope/vim-fugitive'

" Typescrip
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }

" Surround support
Plug 'tpope/vim-surround'

" Tab support
Plug 'gcmt/taboo.vim'

" Snippets
Plug 'SirVer/ultisnips'

" UML
Plug 'aklt/plantuml-syntax'
Plug 'weirongxu/plantuml-previewer.vim'
Plug 'tyru/open-browser.vim'

" Terraform
Plug 'hashivim/vim-terraform'
Plug 'vim-syntastic/syntastic'
Plug 'juliosueiras/vim-terraform-completion'

" Which-Key
Plug 'liuchengxu/vim-which-key'

" Tree
Plug 'kyazdani42/nvim-web-devicons' 
Plug 'kyazdani42/nvim-tree.lua'

" Initialize plugin system
call plug#end()
