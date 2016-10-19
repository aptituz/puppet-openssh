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
# [*ca_key*]
#    Specify path to a ca key on the puppetmaster. If set a host certificate
#    will be generated signed by the given ca. Note that this ca key
#    has to exist in advance.
#
#
# == Author:
#
#    Patrick Schoenfeld <patrick.schoenfeld@credativ.de>
#
class ssh::server (
    $ensure                     = $ssh::params::ensure,
    $ensure_running             = $ssh::params::ensure_running,
    $ensure_enabled             = $ssh::params::ensure_enabled,
    $manage_config              = $ssh::params::manage_config,
    $manage_known_hosts         = $ssh::params::manage_known_hosts,
    $manage_hostkey             = $ssh::params::manage_hostkey,
    $config_template            = $ssh::params::config_template,
    $hostkey_name               = $ssh::params::hostkey_name,
    $hostaliases                = $ssh::params::hostaliases,
    $server_package             = $ssh::params::server_package,
    $service_name               = $ssh::params::service_name,
    $permit_root_login          = $ssh::params::permit_root_login,
    $listen_address             = $ssh::params::listen_address,
    $options                    = $ssh::params::options,
    $ca_key                     = $ssh::params::ca_key,
    $trusted_cert_authorities   = $ssh::params::trusted_cert_authorities,
    $additional_known_hosts     = $ssh::params::additional_known_hosts,
    ) inherits ssh::params {

    validate_re($permit_root_login,
        ['yes', 'no', 'without-password', 'forced-commands-only']
    )

    validate_array($hostaliases)

    ensure_packages([$server_package], { 'ensure' => $ensure })

    if $manage_config {
        file { '/etc/ssh':
            ensure => directory,
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
            before => Concat['/etc/ssh/sshd_config']
        }

        concat::fragment { 'sshd_config_base':
            content => template($config_template),
            target  => '/etc/ssh/sshd_config',
            order   => '01',
        }

        concat { '/etc/ssh/sshd_config':
            owner           => 'root',
            group           => 'root',
            mode            => '0644',
            notify          => Service[$service_name],
            require         => Package[$server_package],
            #Disabled until we can upgrade concat to support this
            #validate_cmd    => '/usr/sbin/sshd -t -f %',
        }
    }

    service { $service_name:
        ensure     => $ensure_running,
        enable     => $ensure_enabled,
        hasrestart => true,
        hasstatus  => true,
        require    => [
            Concat['/etc/ssh/sshd_config'],
            Package[$server_package]
        ],
    }

    class { '::ssh::hostkey':
        manage_hostkey => $manage_hostkey,
        hostkey_name   => $hostkey_name,
        hostaliases    => $hostaliases,
        ca_key         => $ca_key,
    } ~>
    class { '::ssh::known_hosts':
        manage                   => $manage_known_hosts,
        manage_hostkey           => $manage_hostkey,
        hostaliases              => $hostaliases,
        trusted_cert_authorities => $trusted_cert_authorities,
        additional_known_hosts   => $additional_known_hosts,
    }
}
