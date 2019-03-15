#!/usr/bin/env bash

set -u
set -e
set -o pipefail

readonly MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

readonly SONOBUOY="${SONOBUOY:-sonobuoy}"
readonly PLUGIN_NAME="${PLUGIN_NAME:-chkrootkit}"
readonly PLUGIN_CONF_FILE="${PLUGIN_CONF_FILE:-${MY_DIR}/chkrootkit.yaml}"

addPluginConf() {
  jq --arg name "$1" --arg content "$2" '(
    select(.metadata.name == "sonobuoy-plugins-cm") |
      .data[$name] = $content
  ) // .'
}

addPlugin() {
  # - find a doc with metadata > name == sonobuoy-config-cm
  #   - get data > config.json
  #     - convert that from a string into json
  #       - find .Plugins and append a new plugin to that list
  #     - convert back from json to string
  #   - set data > config.json to that string
  # - all other docs: don't do anything
  yq --arg plugin "$1" '(
    select(.metadata.name == "sonobuoy-config-cm") |
      (.data["config.json"] | select(.)) |= (fromjson | .Plugins += [{"name":$plugin}] | @json)
  ) // .'
}

main() {
  "$SONOBUOY" gen "$@" \
    | addPlugin "$PLUGIN_NAME" \
    | addPluginConf "${PLUGIN_NAME}.yaml" "$( cat "$PLUGIN_CONF_FILE" )"
}

main "$@"
