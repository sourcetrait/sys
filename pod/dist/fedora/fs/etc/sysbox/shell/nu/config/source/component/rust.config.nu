$env.RUSTUP_HOME = ($env.UENV_USR_OF | path join 'rustup')
$env.CARGO_HOME = ($env.UENV_USR_OF | path join 'cargo')
$env.CARGO_TARGET_DIR = ($env.UENV_USR_CACHE | path join 'cargo' 'target')
