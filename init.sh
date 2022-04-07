# Source this file.

bap_path_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "${bap_path_root}/_init.sh"
bap_init "${bap_path_root}"

PROMPT_COMMAND=bap_prompt_command


