$env.UENV_EXPECT_USR = "uenv/desk"
$env.UENV_USR_TRANSIENT = ($env | get -o XDG_RUNTIME_DIR | default {
    mktemp -dp /dev/shm transient.XXXXXX
})
