# The qode prompt: "qode <cwd> <git branch>>", red ">" after a failed command.
function fish_prompt --description "qode prompt"
    set -l last_status $status
    set -l mark (set_color green)">"(set_color normal)
    test $last_status -ne 0; and set mark (set_color red)">"(set_color normal)
    echo -n (set_color --bold cyan)qode(set_color normal) (set_color blue)(prompt_pwd)(set_color normal)(fish_vcs_prompt) "$mark "
end
