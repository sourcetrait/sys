$env.npm_config_cache = ($env.UENV_USR_OF | path join 'npm')
$env.npm_config_userconfig = ($env.UENV_USR_CONFIG | path join 'npm' 'npm.rc')
$env.NODE_REPL_HISTORY = ($env.UENV_USR_CACHE | path join 'nodejs' 'history')
