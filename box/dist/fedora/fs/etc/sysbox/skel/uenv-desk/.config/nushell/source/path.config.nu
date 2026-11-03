$env.PATH = ($env.PATH   | append [
    ($env.UENV_USR_ADHOC | path join 'bin')
    ($env.UENV_USR_LOCAL | path join 'bin')
    ($env.UENV_USR_OF    | path join 'cargo' 'bin')
    ($env.UENV_USR_OF    | path join 'python' 'bin')
])
