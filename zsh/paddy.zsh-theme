# paddy.zsh-theme
# Theme is primarily based on https://github.com/benmatselby/dotfiles/blob/master/zsh/benmatselby.zsh-theme

local ret_status="%(?:%{$fg[green]%}✔︎ :%{$fg[red]%}✘ )"
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

if [ -z "${REMOTE_CONTAINERS}" ]; then
  name="paddy in 🐳"
else
  name="paddy"
fi

# color vars
eval my_gray='$FG[246]'
eval my_orange='$FG[214]'

prompt_aws() {
  [[ -z "$AWS_PROFILE" ]] && return
  echo "${my_orange}(☁️  ${AWS_PROFILE})${reset_color}"
}


# primary prompt
PROMPT='
${ret_status} $my_gray $name @ %*%{$reset_color%}%  $FG[032]%~ \
$(git_prompt_info)$(prompt_aws) \
%{$fg_bold[cyan]%}$(tf_prompt_info)%{$reset_color%} \
$FG[105]%(!.#.»)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='${return_code}'

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX="$FG[075]($FG[078]"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="$my_orange*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$FG[075])%{$reset_color%}"
