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

# prefix k8s info onto existing PS1
export PS1="\[${YELLOW}\]\$(_kube_ps1)\[${NORMAL}\]"$PS1
export PS1="\[${YELLOW}\]\$(_awsvault_ps1)\[${NORMAL}\]"$PS1
