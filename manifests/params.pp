# = Class: ssh::params
class ssh::params {
    $ensure             = present
    $ensure_running     = true
    $ensure_enabled     = true
    $manage_config      = true
    $manage_hostkey     = false
    $manage_known_hosts = true
    $config_template    = 'ssh/sshd_config.erb'
    $permit_root_login  = 'no'
    $listen_address     = '0.0.0.0'
    $hostkey_name       = $::fqdn
    $hostaliases        = []
    $ca_key             = undef

    $options            = {}

    case $::osfamily {
        'Debian': {
            $service_name = 'ssh'
            $client_package = 'openssh-client'
        }
        'RedHat': {
            $service_name = 'sshd'
            $client_package = 'openssh-clients'
        }
        default: {
            fail('unsupported platform')
        }
    }

}
