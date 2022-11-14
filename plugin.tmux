#!/usr/bin/env bash

set -ex

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function show_menu() {
  ifaces=$(ip -j addr show | jq '[ .[] | select(.addr_info[0].local != null and .ifname != "lo") | {"iface":.ifname,"addr":.addr_info[0].local} ]')
  start=0
  ifaces_count=$(jq -r '. | length' <<< $ifaces)

  menu_body=()
  for (( i=0; i<$ifaces_count; i++ )); do
    iface="$(jq -r --argjson i $i '.[$i] | "\(.iface)"' <<< $ifaces)"
    addr="$(jq -r --argjson i $i '.[$i] | "\(.addr)"' <<< $ifaces)"

    menu_body=("${menu_body[@]}" "#[align=left]${iface} #[align=right]${addr}")
    menu_body=("${menu_body[@]}" "")
    menu_body=("${menu_body[@]}" "run -b 'printf \"%s\" $addr | xclip -selection clipboard'")
  done

  tmux display-menu -T "#[align=centre]Available networks" -x R -y P "${menu_body[@]}"
}


tmux bind-key -T prefix "M-n" run-shell -b "$CURRENT_DIR/scripts/show_network_interfaces.sh"
