# = CLass: ssh::hostkey
class ssh::hostkey (
    $manage_hostkey,
    $hostkey_name,
    $ca_key = undef,
    $hostaliases = undef,
) {

    if $manage_hostkey {
        # generate and store key on master
        $rsa_priv = ssh_keygen({
            'request'     => 'private',
            'hostkey'     => true,
            'hostaliases' => $hostaliases,
            'comment'     => $::fqdn,
            'type'        => 'rsa',
            'name'        => "ssh_host_rsa_${hostkey_name}",
            'dir'         => 'ssh/hostkeys',
        })
        $rsa_pub  = ssh_keygen({
            'request' => 'public',
            'type'    => 'rsa',
            'name'    => "ssh_host_rsa_${hostkey_name}",
            'dir'     => 'ssh/hostkeys',
            'public'  => true,
        })

        if $ca_key {
            ssh::certificate { '/etc/ssh/ssh_host_rsa_key-cert.pub':
                ensure              => 'present',
                certificate_id      => $::fqdn,
                public_key          => $rsa_pub,
                ca_key_file         => $ca_key,
                host_certificate    => true,
                options             => {
                    'principals' => concat($hostaliases, $::fqdn)
                }
            }

            # Configures a host certificate for the sshd on this host
            # Should probably be moved to the ssh module and generalized
            ssh::server::custom_config { 'HostCertificate':
                order   => 02,
                content => "
# host certificate configured via ssh::hostkey
HostCertificate /etc/ssh/ssh_host_rsa_key-cert
"
            }
        }

        file { '/etc/ssh/ssh_host_rsa_key':
            owner   => 'root',
            group   => 'root',
            mode    => '0600',
            content => $rsa_priv,
            notify  => Service[$ssh::params::service_name],
        }
        file { '/etc/ssh/ssh_host_rsa_key.pub':
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => "ssh-rsa ${rsa_pub} host_rsa_${::hostname}\n",
        }

        # generate and store key on master
        $dsa_priv = ssh_keygen({
            'request'     => 'private',
            'hostkey'     => true,
            'hostaliases' => $hostaliases,
            'comment'     => $::fqdn,
            'type'        => 'dsa',
            'name'        => "ssh_host_dsa_${hostkey_name}",
            'dir'         => 'ssh/hostkeys',
        })
        $dsa_pub  = ssh_keygen({
            'request' => 'public',
            'type'    => 'dsa',
            'name'    => "ssh_host_dsa_${hostkey_name}",
            'dir'     => 'ssh/hostkeys',
            'public'  => true,
        })

        file { '/etc/ssh/ssh_host_dsa_key':
            owner   => 'root',
            group   => 'root',
            mode    => '0600',
            content => $dsa_priv,
            notify  => Service[$ssh::params::service_name],
        }
        file { '/etc/ssh/ssh_host_dsa_key.pub':
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => "ssh-dsa ${dsa_pub} host_dsa_${::hostname}\n",
        }

        # generate and store key on master
        $ecdsa_priv = ssh_keygen({
            'request'     => 'private',
            'hostkey'     => true,
            'hostaliases' => $hostaliases,
            'comment'     => $::fqdn,
            'type'        => 'ecdsa',
            'name'        => "ssh_host_ecdsa_${hostkey_name}",
            'dir'         => 'ssh/hostkeys',
        })
        $ecdsa_pub  = ssh_keygen({
          'request' => 'public',
          'type'    => 'ecdsa',
          'name'    => "ssh_host_ecdsa_${hostkey_name}",
          'dir'     => 'ssh/hostkeys',
          'public'  => true,
        })

        file { '/etc/ssh/ssh_host_ecdsa_key':
            owner   => 'root',
            group   => 'root',
            mode    => '0600',
            content => $ecdsa_priv,
            notify  => Service[$ssh::params::service_name],
        }
        file { '/etc/ssh/ssh_host_ecdsa_key.pub':
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => "ssh-ecdsa ${ecdsa_pub} host_ecdsa_${::hostname}\n",
        }


    }
}


