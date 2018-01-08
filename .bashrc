# put this someplace like ~/.bashrc
NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)

_kube_ps1() {
  local K8S_CONTEXT=$(kubectl config current-context 2> /dev/null || true)
  local K8S_NS=$(kubectl config view ${K8S_CONTEXT} \
    --output json | jq ".contexts[] | select(.name==\"${K8S_CONTEXT}\") | .context.namespace" | tr -d '"' || true)
  [[ -n ${K8S_CONTEXT} ]] && echo "${K8S_CONTEXT%%.*}:${K8S_NS} "
}

# prefix k8s info onto existing PS1
export PS1="\[${YELLOW}\]\$(_kube_ps1)\[${NORMAL}\]"$PS1
