# Prompt
set -o pipefail
autoload -Uz colors; colors
if [ ${UID} -eq 0 ]; then # if Root
  PROMPT="${fg[red]}[%n:${HOST}] ${reset_color}@${fg[white]} %D{%Y-%m-%d %H:%M:%S}
%{${fg_bold[yellow]}%}%~%{${reset_color}%}
# "
else
  PROMPT="${fg[cyan]}[%n:${HOST}] ${reset_color}@${fg[white]} %D{%Y-%m-%d %H:%M:%S}
%{${fg_bold[yellow]}%}%~%{${reset_color}%}
$ "
fi

# zsh settings
autoload -U compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt magic_equal_subst
setopt list_types
unsetopt no_match
setopt IGNOREEOF
setopt AUTO_CD
setopt SH_WORD_SPLIT
unset zle_bracketed_paste # disable ^[[2004h
bindkey -a '^[[3${HOME}' delete-char # <DEL> to be {lower,upper}case
zstyle ':completion:*' list-colors "${LS_COLORS}"

if type exa &>/dev/null;then
  alias ls="/usr/bin/exa --long -m --time-style iso"
else
  alias ls="/usr/bin/ls --color=auto"
fi
alias ll="ls -lag"

# aliases and functions
# {{{
# Error print to stderr
err() {
  # {{{
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
} # }}}
# Require commands
require() {
  # {{{
  is_ok=true
  for cmd in $*; do
    if ! (type $cmd &>/dev/null); then
      err "command '$cmd' is required."
      is_ok=false
    fi
  done
  [ $is_ok != true ] && return 1
  return 0
} # }}}

# Record
# function rec() {
#     # {{{
#     if echo $(hostname) | fgrep -q laptop; then
#         if !(type arecord&>/dev/null); then
#             echo "arecord is not installed"
#             return
#         fi
#         [ ! -d "${HOME}/Music/Records" ] && mkdir -p "${HOME}/Music/Records"
#         arecord -f S16_LE -r 44100 "${HOME}/Music/Records/$(date "+%Y.%m.%d;%H:%M:%S").wav"
#     fi
# } # }}}

# LINE notify
rep() {
  # {{{
  require curl || return
  [ ! -z "${LINE_NOTIFY_TOKEN}" ] || return $(err "env_var 'LINE_NOTIFY_TOKEN' must be set.")
  local message=$1
  if [ $# -ne 1 ] || [ -z "${message}" ]; then
    return $(err 'usage: `rep some_message_you_want`')
  fi
  curl -Ss -X POST \
    -H "Authorization: Bearer ${LINE_NOTIFY_TOKEN}" \
    -F "message=$message" \
    https://notify-api.line.me/api/notify
  } # }}}

# Desktop notify
n() {
  # {{{
  require notify-send || return
  notify-send $*
} # }}}

# rsync & rm -rf
rmSync() {
  # {{{
  require rsync notify-send rm ls || return
  while read f; do
    if [ "$f" = '.' ] || [ "$f" = '..' ]; then continue; fi
    rsync -Pr "$1/$f" "$2"
    if [ $? -eq 0 ]; then
      rm -rf "$1/$f"
    else
      n 'rmSyncFailed'
      rm -rf "$2/$f"
      break
    fi
    n 'rmSyncDone'
  done< <(/usr/bin/ls -a "$1")
} # }}}

# p*xz compress
pxc() {
  # {{{
  require pixz tar pv du awk rm sed || return
  [ $# -eq 0 ] && return $(err 'Quets must be set like `pxc "folder_to_compress/"`')
  for f in "$@"; do
    f=$(echo "$f"|sed 's~/$~~')
    [ ! -e "$f" ] && continue
    tar cf - "$f" -P \
      | pv -s $(du -sb "$f" \
      | awk '{print $1}') \
      | pixz -9 -- \
      > "$f.tar.xz"
    [ $? -ne 0 ] && rm -rf "$f.tar.xz"
  done
}
# }}}

# p*xz decompress
pxx() {
  # {{{
  require pixz tar || return
  [ $# -eq 0 ] && return $(err 'Quets must be set like `pxx "folder_to_decompress.tar.xz"`')
  for f in "$@"; do
    [ ! -e "$f" ] && continue
    tar xf "$f" --use-compress-prog=pixz
  done
}
# }}}

# # Encrypt disk
# function enc() {
#   # {{{
#   # if !(type lsblk&>/dev/null) || !(type cryptsetup&>/dev/null); then
#   # fi
#   printf "Disks: $(lsblk)"
#   echo "ok?(y/N): "
#   if read -q; then
#     echo hello
#   else
#     echo abort
#   fi
#   while read t; do
#     # rsync -Pr "$1/$f" "$2"
#     # if [ $? -ne 0 ]; then
#     #   notify-send 'rmSyncFailed'
#     #   rm -rf "$2/$f"
#     #   break
#     # else
#     #   rm -rf "$1/$f"
#     # fi
#   done
# } # }}}

# Completions
# {{{
_rsync() {
  _path_files -f
}
compdef _rsync rsync
__git_files() { _files }
# }}}

rand() {
  # {{{
  local range max to_clipboard randstr
  local -A opthash
  zparseopts -D -A opthash -- i -int w -week c -clipboard
  if [[ -n "${opthash[(i)-i]}" ]] || [[ -n "${opthash[(i)--int]}" ]]; then
    range='0-9'
  elif [[ -n "${opthash[(i)-w]}" ]] || [[ -n "${opthash[(i)--week]}" ]]; then
    range='0-9a-zA-Z'
  else
    range='0-9a-zA-Z\^$/|()[]{}.,?!_=&@${HOME}%#:;'
  fi
  to_clipboard=0
  if [[ -n "${opthash[(i)-c]}" ]] || [[ -n "${opthash[(i)--clipboard]}" ]]; then
    to_clipboard=1
  fi

  if [ $# -eq 1 ];then
    count=$(($1))
  else
    count=100
  fi
  randstr="$(cat /dev/urandom|tr -dc $range|head -c $count)"
  if [ $to_clipboard -eq 1 ];then
    echo -n "$randstr"|xsel -bi
  else
    echo $randstr
  fi
}
#}}}

keygen() {
  # {{{
  local comment path
  local -A opthash
  zparseopts -D -A opthash -- f: -file:
  path="${HOME}/.ssh/id_ed25519"
  if [[ -n "${opthash[(i)-f]}" ]];then
    path="${opthash[-f]}"
  elif [[ -n "${opthash[(i)--file]}" ]];then
    path="${opthash[--file]}"
  fi

  if [ $# -eq 1 ];then
    comment="$1"
  else
    comment="$HOST"
  fi
  /usr/bin/ssh-keygen -o -a 100 -t ed25519 -f "$path" -C "$comment"
}
#}}}

rust() {
  # {{{
  if (!type cargo &>/dev/null); then
    echo "This function needs 'cargo'"
    return 1
  fi
  if (!type systemfd &>/dev/null); then
    echo "This function needs 'systemfd'"
    echo "please 'cargo install systemfd'"
    return 1
  fi
  local port mode
  local -A opthash
  zparseopts -D -A opthash -- p: t v
  port=3000
  if [[ -n "${opthash[(i)-p]}" ]];then
    port="${opthash[-p]}"
  fi

  mode='run'
  if [[ -n "${opthash[(i)-t]}" ]];then
    mode='test'
  fi
  if [[ -n "${opthash[(i)-v]}" ]];then
    mode='vue'
  fi

  if [ "${mode}" = 'vue' ];then
    systemfd --no-pid -s http::"${port}" -- cargo watch -i 'static/*' -s 'cd vue && yarn build && cd .. && cargo run'
  else
    systemfd --no-pid -s http::"${port}" -- cargo watch -x ${mode}
  fi
}
#}}}

cnv() {
  # {{{
  require cat nkf
  for inp in "$@"; do
    local temp=$(mktemp)
    if [ ! -n "$inp" ] || [ ! -n "$temp" ]; then
      return $(err "Specify argument")
    fi
    cat "$inp"|nkf > "$temp" \
      && mv "$temp" "$inp"
  done
} # }}}

wgetAll() {
  # {{{
  wget \
    --mirror \
    --page-requisites \
    --quiet \
    --show-progress \
    --no-parent \
    --convert-links \
    --adjust-extension \
    --execute robots=off \
    "$@"
} # }}}

u() {
  # {{{
  require loginctl || return
  loginctl unlock-session $*
} # }}}

bakup() {
  # {{{
  require tar pv pixz du xargs awk realpath || return
  local args=()
  local ignores=()
  while (( $# > 0 )); do
    case $1 in
      -*)
        if [[ "$1" =~ 'i' ]]; then
          ignores+=("$2")
          shift
        fi
        shift
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done
  [ ${#args} -ne 2 ] && return $(err 'usage: `backup srcDir dstDir [-i ignoreDir1 -i ignoreDir2]`')
  local srcDir="${args[1]}"
  local dstDir="${args[2]}"

  mkdir -p $dstDir

  local isIncomplete=''
  while read srcNode; do
    if [ "$srcNode" = '.' ] || [ "$srcNode" = '..' ]; then continue; fi
    if [ "$(find /tmp -name 'bakupLog-*' 2>/dev/null)" ] && [ ! -f "/tmp/bakupLog-$srcNode" ]; then
      isIncomplete=1
      echo "restarting from previous operation. ignore $srcNode"
      continue
    else
      touch "/tmp/bakupLog-$srcNode"
    fi
    src="$(realpath "$srcDir/$srcNode")"

    if [[ "${ignores[@]}" =~ "${srcNode}" ]]; then
      echo "Backup: '$src' is in ignores list. ignore"
      rm "/tmp/bakupLog-$srcNode"
      continue
    fi
    if [[ ! "$src" =~ "^$srcDir" ]]; then
      echo "Backup: '$src' is a symlink. ignore"
      rm "/tmp/bakupLog-$srcNode"
      continue
    fi
    srcSize="$(du -s "$src"|awk '{print $1}')"
    srcHash="$(find "$src"|LC_ALL=C sort|md5sum|awk '{print $1}')"
    dst="$(realpath "$dstDir/$srcNode")-$srcHash-$srcSize.tar.xz"
    if [ -f "$dst" ] \
      && [ "$(du -s "$dst"|awk '{print $1}')" -ne 0 ] \
      && [ ! $isIncomplete ] \
      ; then
      echo "Backup: '$src' is not changed. ignore"
      rm "/tmp/bakupLog-$srcNode"
      continue
    fi
    echo "Backing up: '$src' -> '$dst'"
    tar cf - "$src" -P \
      | pv -s $(du -sb "$src"|awk '{print $1}') \
      | pixz -9 -- \
      > "$dst"
    rm "/tmp/bakupLog-$srcNode"
    isIncomplete=''
  done< <(/usr/bin/ls -a "$srcDir")
} # }}}

combineVideos() {
  # {{{
  require ffmpeg || return
  [ $# -le 3 ] && return $(err 'usage: `combineVideos srcA.mp4 srcB.mp4 out.mp4`')
  local catFiles=("$@")
  local outFile=${catFiles[-1]}
  unset catFiles[-1]
  local content=''
  for catFile in "${catFiles[@]}"; do
    [ -z $catFile ] && continue
    content+="file '$(realpath "$catFile")'\n"
  done
  local tmp=$(mktemp)
  echo -e $content > $tmp
  ffmpeg -safe 0 -f concat -i "$tmp" -c:v copy -c:a copy -c:s copy -map 0:v -map 0:a -map 0:s? "$outFile"
  # rm "$tmp"
} # }}}

clearCache() {
  # {{{
  require sync tee || return
  sync && echo 3 | sudo tee /proc/sys/vm/drop_caches && swapoff -a && swapon -a
} # }}}


require scp && alias scp='scp -c aes256-ctr -pq'
require bat && alias cat='bat'

# }}}

# For Vimmer
bindkey -v
alias vi='vim'
alias v='vim'
alias ssh='TERM=xterm-256color ssh'
type dstat &>/dev/null && alias dstat="dstat -tlafm --tcp"

# Compile .zshrc
if [ -f "${HOME}/.zshrc" ] && [ ! -f "${HOME}/.zshrc.zwc" ] || [ "${HOME}/.zshrc" -nt "${HOME}/.zshrc.zwc" ]; then
  zcompile ${HOME}/.zshrc
fi

# Xmodmap
if [[ -f "${HOME}/.zprofile" ]] && [[ ! $(cat "${HOME}/.zprofile"|fgrep 'type xmodmap&>/dev/null && xmodmap ${HOME}/.Xmodmap') ]]; then
  echo '[[ -f ${HOME}/.Xmodmap ]] && type xmodmap&>/dev/null && xmodmap ${HOME}/.Xmodmap' >> "${HOME}/.zprofile"
fi

