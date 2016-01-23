# = Type: ssh::server::custom_config
define ssh::server::custom_config (
    $content,
    $order     = 250,
    $target    = '/etc/ssh/sshd_config'
) {
    concat::fragment { "sshd_config_custom_config_${name}":
        target  => $target,
        content => $content,
        order   => $order,
    }
}
