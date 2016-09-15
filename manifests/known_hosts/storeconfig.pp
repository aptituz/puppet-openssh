# = Class: ssh::known_hosts::storeconfig
#
# Manages a global known_hosts file (based on storeconfig)
#
class ssh::known_hosts::storeconfig (
    $hostaliases        = undef,
) {
    if ! $hostaliases {
        warning("ssh::known_hosts::storeconfig: no hostaliases specified. using defaults (fqdn, ipaddress) for now, but this will soon be obsoleted")
        $used_hostaliases = [$::fqdn, $::ipaddress]
    } else {
        $used_hostaliases = $hostaliases
    }
    # Export our own ssh key
        @@sshkey { $::hostname:
            host_aliases => $used_hostaliases,
            type         => rsa,
            key          => $::sshrsakey
        }

        Sshkey <<| |>>

        # WORKAROUND FOR http://projects.reductivelabs.com/issues/2014
        # ssh_known_hosts file is created with wrong permissions
        file { '/etc/ssh/ssh_known_hosts':
            mode => '0644'
        }
}
