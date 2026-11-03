$env.UENV_EXPECT_USR = "uenv/desk"
$env.UENV_USR_TRANSIENT = ($env | get -o XDG_RUNTIME_DIR | default {
    mktemp -dp $env.UENV_USR_TMP transient.XXXXXX
})
