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

          $known_hosts_content = inline_template("
<% trusted_cert_authorities.sort_by { |name| name }.each  do |name, key| -%>
<% if key.is_a?(String) -%>
# key for <%= name %>
@cert-authority * ssh-rsa <%= key %>
<% elsif key.is_a?(Hash) -%>
# key for <%= name %>
@cert-authority <%= key['hostaliases'] || '*' %> <%= key['type'] || 'ssh-rsa' %> <%= key['content'] %>
<% end -%>
<% end -%>
<%= @generated_known_hosts %>
")
          # if we are managing hostkeys, we are using its known_hosts file
          file { '/etc/ssh/ssh_known_hosts':
              mode    => '0644',
              content => $known_hosts_content
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
