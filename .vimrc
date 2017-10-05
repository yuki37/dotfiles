"------------------------------------
" OSの判定
"------------------------------------
if has('win32')
    let ostype = 'Win32'
elseif has('mac')
    let ostype = 'Mac'
else
    let ostype = system('uname')
endif

"------------------------------------
" dein導入
"------------------------------------
if ostype == 'Mac'
    "dein Scripts-----------------------------
    if &compatible
        set nocompatible               " Be iMproved
    endif

    " プラグインが実際にインストールされるディレクトリ
    let s:dein_dir = expand('~/.vim/.cache/dein')
    " dein.vim 本体
    let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

    " dein.vim がなければ github から落としてくる
    if &runtimepath !~# '/dein.vim'
        if !isdirectory(s:dein_repo_dir)
            execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
        endif
        execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
    endif
    " set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim

    " Required:
    if dein#load_state(expand('~/usr/.vim/dein'))
        call dein#begin(expand('~/.vim/dein'))

        " プラグインリストを収めた TOML ファイル
        " 予め TOML ファイル（後述）を用意しておく
        let g:rc_dir    = expand('~/.vim/rc')
        let s:toml      = g:rc_dir . '/dein.toml'
        let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

        " TOML を読み込み、キャッシュしておく
        call dein#load_toml(s:toml,      {'lazy': 0})
        call dein#load_toml(s:lazy_toml, {'lazy': 1})

        " Required:
        call dein#end()
        call dein#save_state()
    endif

    " Required:
    filetype plugin indent on
    syntax enable

    " If you want to install not installed plugins on startup.
    if dein#check_install()
        call dein#install()
    endif

    "End dein Scripts-------------------------
endif

set modelines=0        " CVE-2007-2438
" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible    " Use Vim defaults instead of 100% vi compatibility
set backspace=2        " more powerful backspacing

au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

"------------------------------------
" JAVA-SCRIPT系の設定
"------------------------------------
" vim-coffee-script
" 保存時にコンパイル
au BufWritePost *.coffee silent make -b
" リアルタイムプレビュー
" au BufWritePost *.coffee :CoffeeWatch vert

" jasmine.vim
" ファイルタイプを変更
function! JasmineSetting()
    au BufRead,BufNewFile *Helper.js,*Spec.js  set filetype=jasmine.javascript
    au BufRead,BufNewFile *Helper.coffee,*Spec.coffee  set filetype=jasmine.coffee
    au BufRead,BufNewFile,BufReadPre *Helper.coffee,*Spec.coffee  let b:quickrun_config = {'type' : 'coffee'}
    call jasmine#load_snippets()
    map <buffer> <leader>m :JasmineRedGreen<CR>
    command! JasmineRedGreen :call jasmine#redgreen()
    command! JasmineMake :call jasmine#make()
endfunction
au BufRead,BufNewFile,BufReadPre *.coffee,*.js call JasmineSetting()
" indent_guides
" インデントの深さに色を付ける
let g:indent_guides_start_level=2
let g:indent_guides_auto_colors=0
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_color_change_percent=20
let g:indent_guides_guide_size=1
let g:indent_guides_space_guides=1

hi IndentGuidesOdd  ctermbg=235
hi IndentGuidesEven ctermbg=237
au FileType coffee,ruby,javascript,python IndentGuidesEnable
nmap <silent><Leader>ig <Plug>IndentGuidesToggle
autocmd BufNewFile,BufRead *.coffee setlocal tabstop=2 softtabstop=2 shiftwidth=2

"------------------------------------
" C++
"------------------------------------
" 保存時にコンパイル
"au BufWritePost *.cpp silent :gcc 
au BufWritePost *.cpp :lcd %:h | :!gcc %:p 1>/dev/null


"------------------------------------
" プログラム言語共通の設定
"------------------------------------
" コンパイルエラー時の処理
au QuickFixCmdPost * nested cwindow | redraw! 


"------------------------------------
" 雑多な設定
"------------------------------------
if has("syntax")
    syntax on
endif

set number
set expandtab
set tabstop=4
set ambiwidth=double
set shiftwidth=4 
set smartindent
set wrap
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set nrformats-=octal
set hidden
set history=50
set virtualedit=block
set whichwrap=b,s,[,],<,>
set backspace=indent,eol,start
set wildmenu

set foldmethod=marker
set ignorecase
set mouse=a

colorscheme molokai
set t_Co=256

" ###########################################################
" 補完の設定
" ###########################################################
highlight Pmenu ctermbg=4
highlight PmenuSel ctermbg=1
highlight PMenuSbar ctermbg=4

set completeopt=menuone
let g:rsenseUseOmniFunc = 1
let g:auto_ctags = 1
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_enable_camel_case_completion  =  1
let g:neocomplcache_enable_auto_select = 1
let g:neocomplcache_max_list = 20
let g:neocomplcache_min_syntax_length = 3
autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.ruby = '[^.*\t]\.\w*\|\h\w*::'

if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'


" ###########################################################
" キーマッピング
" ###########################################################
" dein update
" noremap du :call dein#update()<CR>
" Plugin shortcut
noremap vf :VimFiler<CR>
noremap vs :VimShell<CR>

inoremap { {}<Left>
inoremap ( ()<Left>
inoremap < ()<Left>
inoremap [ []<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>
" 画面移動を素早く
noremap <S-h>   ^
noremap <S-j>   }
noremap <S-k>   {
noremap <S-l>   $

" ==でインデント調整
nnoremap == gg=G''

" 検索結果を画面の中央に
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz


nnoremap ; :
nnoremap : ;
nnoremap x "_x

" 行移動を表示行での移動に
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" 画面分割系統
nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap sn gt
nnoremap sp gT
nnoremap sr <C-w>r
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap sT :<C-u>Unite tab<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sq :<C-u>q<CR>
nnoremap sQ :<C-u>bd<CR>
nnoremap sb :<C-u>Unite buffer_tab -buffer-name=file<CR>
nnoremap sB :<C-u>Unite buffer -buffer-name=file<CR>

" 廃止
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
nnoremap Q gq

" Paste Setting
if &term =~ "xterm"
    let &t_ti .= "\e[?2004h"
    let &t_te .= "\e[?2004l"
    let &pastetoggle = "\e[201~"
    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction
    noremap <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
    cnoremap <special> <Esc>[200~ <nop>
    cnoremap <special> <Esc>[201~ <nop>
endif

" call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
" call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
" call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
" call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
" call submode#map('bufmove', 'n', '', '>', '<C-w>>')
" call submode#map('bufmove', 'n', '', '<', '<C-w><')
" call submode#map('bufmove', 'n', '', '+', '<C-w>+')
" call submode#map('bufmove', 'n', '', '-', '<C-w>-')


