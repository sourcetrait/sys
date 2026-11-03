def __prompt_pwd []: nothing -> string {
    let home = $env.HOME
    let pwd = $env.PWD
    if $pwd == $home { return "~" }
    if $pwd == "/" { return "/" }
    if ($pwd | str starts-with $"($home)/") {
        let comps = ($pwd | str replace $"($home)/" "" | path split | where {|c| $c != "/" })
        if ($comps | length) <= 2 {
            $"~/($comps | str join '/')"
        } else {
            $"($comps | last 2 | str join '/')"
        }
    } else {
        let comps = ($pwd | path split | where {|c| $c != "/" })
        if ($comps | length) <= 2 {
            $"/($comps | str join '/')"
        } else {
            $"($comps | last 2 | str join '/')"
        }
    }
}

def __prompt_git_branch []: nothing -> string {
    match (^git branch --show-current | complete | get stdout | default '' | str trim) {
        '' => '',
        $s => $" \(($s)\)"
    }
}

$env.PROMPT_COMMAND       = {|| $"(ansi ($env | get -o PROMPT_COLOR_USERNAME | default blue))($env.USER)(ansi ($env | get -o PROMPT_COLOR_AT | default purple))@(ansi ($env | get -o PROMPT_COLOR_HOSTNAME | default grey))($env.HOSTNAME) (ansi ($env | get -o PROMPT_COLOR_INDICATOR | default green))(__prompt_pwd)(ansi ($env | get -o PROMPT_COLOR_BRANCH | default purple))(__prompt_git_branch)(ansi reset)" }
$env.PROMPT_INDICATOR     = {|| "> " }
$env.PROMPT_COMMAND_RIGHT = {|| "" }
