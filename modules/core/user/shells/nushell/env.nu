# Nushell Environment Config File
#
# version = "0.92.2"

$env.PROMPT_COMMAND = {||
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"
    let shell_name = if ($env.name? | is-not-empty) {
        $"(ansi blue_bold)\((if ($env.name == "devenv-shell-env") { "devenv" } else { $env.name })\)(ansi reset) "
    } else { "" }

    $"($shell_name)($path_segment)" | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| "" }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
# use std "path add"
# $env.PATH = ($env.PATH | split row (char esep))
# path add ($env.CARGO_HOME | path join "bin")
# path add ($env.HOME | path join ".local" "bin")
# $env.PATH = ($env.PATH | uniq)

# To load from a custom file you can use:
# source ($nu.default-config-dir | path join 'custom.nu')

$env.PATH = ($env.PATH | append '~/.cargo/bin')

# $env.CARGO_TARGET_DIR = "/home/real/target"
alias cat = bat
alias df = duf
alias ns = nix-shell -p --command "nu"
alias search = nix-search
alias tree = tree -l # Make `tree` follow symlinks
alias clone = git clone --depth 1 # Shallow git clone
alias shell = nix-shell --command "nu"
alias lg = lazygit
alias switch = nh os switch ~/dotfiles

def nsr [pkg] {
	nix-shell -p $pkg --command $pkg
}

def mkcd [name] {
	mkdir $name; cd $name
}

# Alias to helix
def v [...args] {
    if ($args | is-empty) {
        hx .
    } else {
        hx ...$args
    }
}

# Recent project picker
def p [action?: string, project_path?: string] {
    let recent_projects_file = ($env.HOME | path join ".cache/recent-projects")

    mkdir ($recent_projects_file | path dirname) | ignore

    match $action {
        "add" => { add_project $project_path $recent_projects_file }
        "list" => { list_projects $recent_projects_file }
        "clear" => { clear_projects $recent_projects_file }
        "pick" => { pick_project $recent_projects_file }
        _ => { pick_project $recent_projects_file }
    }
}

def add_project [project_path: string, recent_projects_file] {
  if ($project_path | is-empty) {
    print "Usage: recent-projects add /path/to/project"
    return
  }
    
  if not ($recent_projects_file | open | lines | any { |line| $line == $project_path }) {
    $project_path | save --append $recent_projects_file
  }
}

def list_projects [recent_projects_file] {
  open $recent_projects_file | lines | each { |line| print $line }
}

def clear_projects [recent_projects_file] {
  "" | save -f $recent_projects_file
  print "Cleared recent projects."
}

def open_project [project_path: string, recent_projects_file] {
  if not ($project_path | path exists) {
    print "Project directory does not exist: ($project_path)"
    return
  }

  cd $project_path
  hx .
}

def pick_project [recent_projects_file] {
  if (ls $recent_projects_file | get size) == 0 {
    print "No recent projects found."
    return
  }
    
  let selected = ($recent_projects_file | open | lines | to text | fzf)
  if not ($selected | is-empty) {
    open_project $selected $recent_projects_file
  }
}
