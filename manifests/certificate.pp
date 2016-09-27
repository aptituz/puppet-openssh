define ssh::certificate (
    $ensure = 'present',
    $certificate_id,
    $public_key,
    $type = 'ssh-rsa',
    $target = $name,
    $host_certificate = false,
    $ca_key_file = '/etc/puppet/id_ca',
    $options = {}
) {
    validate_string($certicate_id)
    validate_bool($host_certificate)
    validate_string($ca_key_file)
    validate_string($public_key)
    validate_hash($options)

    $real_options = merge($options, {
        'host_certificate' => $host_certificate,
    })

    file { $target:
        ensure  => $ensure,
        content => ssh_sign_certificate($ca_key_file, $certificate_id, "$type $public_key", $real_options),
        mode    => '0644',
    }
}
