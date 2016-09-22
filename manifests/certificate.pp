define ssh::certificate {
    $ensure = 'present'
    $certicate_id,
    $public_key,
    $target,
    $host_certificate = false,
    $ca_key_file = '/etc/puppet/id_ca',
    $options
} {
    validate_string($certicate_id)
    validate_bool($host_certificate)

    $real_options = merge($options, {
        'host_certificate' => $host_certificate,
    })

    file { $target:
        ensure  => $ensure
        content => ssh_sign_certificate($ca_key_file, $certicate_id, $public_key, $real_Aoptions)
        mode    => '0644',
    }
}
