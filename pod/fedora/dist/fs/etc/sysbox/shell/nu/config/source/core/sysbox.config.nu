$env.config.show_banner = false

$env.config.history = {
    file_format: sqlite
    isolation: true
    sync_on_enter: true
    max_size: 100_000_000
}

$env.HOSTNAME = (sys host | get hostname)
