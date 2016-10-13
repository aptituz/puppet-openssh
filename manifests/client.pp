# == Class: ssh-client
#
# Manages ssh client
#
# === Parameters
#
# [*ensure*]
# What state the ssh client package should be in.
#

class ssh::client (
  $ensure           = 'present',
  $client_package   = $ssh::params::client_package
  ) inherits ssh::params {
    ensure_packages([$client_package], { 'ensure' => $ensure })
}
