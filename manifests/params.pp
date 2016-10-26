# = Class: ssh::params
class ssh::params {
    $ensure                     = present
    $ensure_running             = true
    $ensure_enabled             = true
    $manage_config              = true
    $manage_hostkey             = false
    $manage_known_hosts         = true
    $config_template            = 'ssh/sshd_config.erb'
    $permit_root_login          = 'no'
    $listen_address             = '0.0.0.0'
    $hostkey_name               = $::fqdn
    $hostaliases                = []
    $ca_key                     = undef
    $trusted_cert_authorities   = undef
    $additional_known_hosts     = undef

    $options            = {}

    case $::osfamily {
        'Debian': {
            $service_name = 'ssh'
            $client_package = 'openssh-client'
            $server_package = 'openssh-server'
            $sftp_server_path = '/usr/lib/openssh/sftp-server'

            # Debian uses PAM to print the MOTD. This has to be disabled so it is not printed twice.
            $default_options = {
                'PrintMotd' => 'no',
            }
        }
        'RedHat': {
            $service_name = 'sshd'
            $client_package = 'openssh-clients'
            $server_package = 'openssh-server'
            $sftp_server_path = '/usr/libexec/openssh/sftp-server'
            $default_options = {}
        }
        'Suse': {
            $service_name = 'sshd'
            $client_package = 'openssh'
            $server_package = 'openssh'
            $sftp_server_path = '/usr/lib/ssh/sftp-server'
            $default_options = {}
        }
        default: {
            fail('unsupported platform')
        }
    }

}
