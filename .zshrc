#プロンプトの表示設定
autoload colors; colors
if [ -w / ] ; then
    PROMPT="[${USER}@${HOST%%.*} %1~]%(!.#.$) "

else
    PROMPT="%{${fg[yellow]}%}%~%{${reset_color}%}
$ "
fi

# 補完の設定
autoload -U compinit
compinit

# 対話モードでプロンプトに ^[[2004hと表示されるのを防ぐ
unset zle_bracketed_paste

# ls の色設定
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
alias ls="ls -GF"
alias gls="gls --color"
zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

# vimの設定
alias vi='vim'
alias v='vim'
alias gt='git log --graph --oneline --all'

# 補完時に大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# コマンドがディレクトリの名前の時に自動的にcdコマンドとして実行する
setopt AUTO_CD

