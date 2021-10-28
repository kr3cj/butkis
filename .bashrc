# put this someplace like ~/.bashrc
# for more advanced features including git branches, see
#  https://github.com/kr3cj/dotfiles/blob/master/home/.bashrc.d/ps1#L15-L59
NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)

_kube_ps1() {
  local K8S_CONTEXT=$(kubectl config current-context 2> /dev/null || true)
  # strip secondary domains
  K8S_CONTEXT="${K8S_CONTEXT%%.*}"
  # strip preceding user@
  K8S_CONTEXT="${K8S_CONTEXT##*@}"`
  local K8S_NS=$(kubectl config view \
    --output json | jq ".contexts[] | select(.name==\"${K8S_CONTEXT}\") | .context.namespace" | tr -d '"' || true)
  [[ -n ${K8S_CONTEXT} ]] && echo "${K8S_CONTEXT}:${K8S_NS} "
}

_awsvault_ps1() {
  [[ -n ${AWS_VAULT} ]] && echo "(aws:${AWS_VAULT}) "
}

# Display the current SAML2AWS profile, if available (inspired by liquidprompt)
P_ENABLE_SAML2AWS=${P_ENABLE_SAML2AWS:-0}
_P_OPEN_ESC="\["
_P_CLOSE_ESC="\]"
BOLD_BLINK_RED_BG="${_P_OPEN_ESC}${ti_bold}$(tput blink ; ti_setaf 7 ; ti_setab 1)${_P_CLOSE_ESC}"
P_COLOR_SAML2AWS=${P_COLOR_SAML2AWS:-${_P_OPEN_ESC}$(ti_setaf 2)${_P_CLOSE_ESC}}
P_COLOR_AWSVAULT_PROD=${P_COLOR_AWSVAULT_PROD:-$BOLD_BLINK_RED_BG}

local ti_sgr0="$( { tput sgr0 || tput me ; } 2>/dev/null )"
NO_COL="${_P_OPEN_ESC}${ti_sgr0}${_P_CLOSE_ESC}"

if [[ ${P_ENABLE_SAML2AWS} && -n "$(command -v saml2aws)" ]]; then
  if [[ -n ${AWS_SESSION_TOKEN} ]]; then
    # detect any assumed roles
    local P_SAML2AWS_ROLE=$(_throttle 30 aws sts get-caller-identity --query Arn --output text \
     2> /dev/null || echo "${P_COLOR_AWSVAULT_PROD}ROLE_TIMED_OUT${NO_COL}")
    # display any assumed role
    if [[ ${P_SAML2AWS_ROLE} =~ ":assumed-role/" ]]; then
      # without using subshell, strip off preceding ".*assumed-role/"
      P_SAML2AWS_ROLE=${P_SAML2AWS_ROLE##*assumed-role/}
      # without using subshell, strip off ending "/.*"
      P_SAML2AWS_ROLE=${P_SAML2AWS_ROLE%%/*}
    fi
    case "${P_SAML2AWS_ROLE}" in
      *prod*)
        P_SAML2AWS="${P_AWS_ICON}${P_COLOR_SAML2AWS_PROD}${MY_AWS_PROFILE}:${P_SAML2AWS_ROLE}${NO_COL} " ;;
      *)
        P_SAML2AWS="${P_AWS_ICON}${P_COLOR_SAML2AWS}${MY_AWS_PROFILE}:${P_SAML2AWS_ROLE}${NO_COL} " ;;
    esac
  fi
else
  P_SAML2AWS=
fi

# prefix k8s info onto existing PS1
export PS1="\[${YELLOW}\]\$(_kube_ps1)\[${NORMAL}\]"$PS1
export PS1="\[${YELLOW}\]\$(_awsvault_ps1)\[${NORMAL}\]"$PS1
export PS1=$PS1"${P_SAML2AWS}"
