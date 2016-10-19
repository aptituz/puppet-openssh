# = Class: ssh::known_hosts
#
# Manges a global known_hosts file
class ssh::known_hosts (
    $manage,
    $manage_hostkey,
    $hostaliases = undef,
    $trusted_cert_authorities = undef,
    $additional_known_hosts = undef,
    ) {
    if $manage {
      if $manage_hostkey {
        $generated_known_hosts = ssh_keygen(
          { 'request' => 'known_hosts', 'dir' => 'ssh/hostkeys' }
        )
      }

      file { '/etc/ssh/ssh_known_hosts':
        ensure        => file,
        owner         => root,
        group         => root,
        mode          => '0644',
        content       => template('ssh/known_hosts.erb'),
      }
    }
}
