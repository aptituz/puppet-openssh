# = Class: ssh::server
#
# Manage SSH on a system
#
# == Parameters:
# 
# [*ensure*]
#    What state to ensure for the package. Accepts the same values
#    as the parameter of the same name for a package type.
#    Default: present
#
#  [*ensure_running*]
#    Whether to ensure running sshd or not.
#    Default: running
#
#  [*ensure_enabled*]
#    Whether to ensure that sshd is started on boot or not.
#    Default: true
#
#  [*manage_config*]
#    Whether to manage sshd_config or not.
#    Default: true
#
# [*manage_hostkey*]
#    Wether to manage the hostkey or not. This is required for
#    manage_known_hosts without storeconfig/puppetdb to work.
#    Default: false
#
# [*manage_known_hosts*]
#    Whether to manage a global known_hosts file or not.
#    Default: true
#
# [*config_template*]
#    Allows specifying what template is used for the sshd_config.
#    Default: 'ssh/sshd_config.erb'
#
# [*permit_root_login*]
#    Whether to permit root login or not.
#     Valid values are: yes, no, without-password and forced-commands-only
#
# [*listen_address*]
#    Define the address the sshd should listen on.
#    Default: 0.0.0.0
#
# == Author:
# 
#    Patrick Schoenfeld <patrick.schoenfeld@credativ.de>
#
class ssh::server (
    $ensure             = $ssh::params::ensure,
    $ensure_running     = $ssh::params::ensure_running,
    $ensure_enabled     = $ssh::params::ensure_enabled,
    $manage_config      = $ssh::params::manage_config,
    $manage_known_hosts = $ssh::params::manage_known_hosts,
    $manage_hostkey     = $ssh::params::manage_hostkey,
    $config_template    = $ssh::params::config_template,
    $hostkey_name       = $ssh::params::hostkey_name,
    $hostaliases        = $ssh::params::hostaliases,
    $service_name       = $ssh::params::service_name,
    $permit_root_login  = $ssh::params::permit_root_login,
    $listen_address     = $ssh::params::listen_address,
    $options            = $ssh::params::options,
    ) inherits ssh::params {

    validate_re($permit_root_login,
        ['yes', 'no', 'without-password', 'forced-commands-only']
    )

    package { 'openssh-server':
        ensure => $ensure,
    }

    if $manage_config {
        file { '/etc/ssh':
            ensure => directory,
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
            before => Concat['/etc/ssh/sshd_config']
        }

        concat::fragment { 'sshd_config_base':
            content => template('ssh/sshd_config.erb'),
            target  => '/etc/ssh/sshd_config',
            order   => '01',
        }

        concat { '/etc/ssh/sshd_config':
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            notify  => Service[$service_name],
            require => Package['openssh-server'],
        }
    }

    service { $service_name:
        ensure     => $ensure_running,
        enable     => $ensure_enabled,
        hasrestart => true,
        hasstatus  => true,
        require    => [
            File['/etc/ssh/sshd_config'],
            Package['openssh-server']
        ],
    }

    class { 'ssh::hostkey':
        manage_hostkey => $manage_hostkey,
        hostkey_name   => $hostkey_name,
        hostaliases    => $hostaliases,
    } ~>
    class { 'ssh::known_hosts':
        manage         => $manage_known_hosts,
        manage_hostkey => $manage_hostkey,
    }
}
