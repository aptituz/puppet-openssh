# = Class: ssh::known_hosts
#
# Manges a global known_hosts file
class ssh::known_hosts (
    $manage,
    $manage_hostkey,
    $hostaliases = undef,
    $trusted_cert_authorities = undef,
    ) {
    if $manage {
      if $manage_hostkey {
          $generated_known_hosts = ssh_keygen(
              { 'request' => 'known_hosts', 'dir' => 'ssh/hostkeys' }
          )
          # if we are managing hostkeys, we are using its known_hosts file
          file { '/etc/ssh/ssh_known_hosts':
              mode    => '0644',
              content => template('ssh/known_hosts.erb')
          }
      } else {
          # storeconfig based implementation is in another class, because
          # otherwise the server is complaining loud if storeconfig is not enabled
          class { 'ssh::known_hosts::storeconfig':
            hostaliases => $hostaliases,
          }
      }
    }
}
