# Puppet module: ssh

[![Build Status](https://travis-ci.org/aptituz/puppet-openssh.svg?branch=master)](https://travis-ci.org/aptituz/puppet-openssh)

#### Table of contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Backwards incompatibility](#backwards-incompatibility)
4. [Setup - The basics of getting started with ssh](#setup)
    * [What ssh affects](#what-ssh-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ssh](#beginning-with-ssh)
5. [Usage - Configuration options and additional functionality](#usage)
6. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
7. [Limitations - OS compatibility, etc.](#limitations)
8. [Development - Guide for contributing to the module](#development)
9. [Contributors](#contributors)

##Overview

This is a puppet module to manage openssh, including management of hostkeys and
a global known_hosts file. Works on puppet >= 3 and Debian- aswell as
RedHat-based systems and (not yet fully tested) on SuSE.

##Module description

openssh is an integral part of most linux infrastructures and this module provides
a way to manage it. Apart from package installation, configuration and service
management, it supports management of a global known_hosts from three sources:

- specified known hosts content via parameter
- based on keys generated by the module, cached on the server and rolled
  out by puppet (enduring re-provisioning and working without storeconfig)
- based on given ssh CA certificates

## Backwards incompatibility
This module has just gone through a refactoring, from the module previously
written for my employer (credativ/puppet-ssh-hiera). It is no longer compatible
to that module, since some of its distinct features (user management) and
specifics have been removed and/or changed. This module is no longer using the
params_lookup function, nor is it managing anything except ssh.

## Setup

### What ssh effects

* openssh package
* openssh configuration
* openssh hostkey
* openssh service
* /etc/ssh/ssh_known_hosts

### Beginning with ssh

If you just want a client installed, you can run include '::ssh::client'.

If you just want a server being installed and managed with default option, you can include '::ssh::server'.

If you need to customize options, such as the ListenAddress of the server or
other configurations, you need to pass an options hash or use the appropriate parameters
for a few often used cases.

```puppet
class { '::ssh::server':
  permit_root_login => 'yes',
  listen_address    => '192.168.1.1',
  options           => $options_hash
}
```

Refer to the template to see what keys can be used in the options hash.
Its also possible to specify an own template via the config_template
parameter.

### Setup requirements

This module does not have specific requirements, except if you want it to
generate and manage the hostkeys of the system. Then its required to
mkdir a directory /etc/puppet/ssh on your puppetmaster host and give it
appropriate permissions so that puppetmaster can create and write files.

If you want to make use of the CA functionalities, you need to create a CA
signing key and store it as /etc/puppet/id_ca (or another key to your liking).
You then have to configure that key in the server class to enable the
CA functionality.

For best use, you should also configure set the $trusted_cert_authorities to all
certification authorities that shall be configured as trusted (for hostkeys).

If you want to use the functionality for user certificates, take a look at
the ssh::certificate resource and make sure, you also deploy authorized_keys
as needed.

##Usage

You can include the classes you need and configure it via the parameters it
supports. Please see the class docs for supported parameters and their
meaning.

### Classes

#### ssh::client

Currently only installs a ssh-client.

#### ssh::server

Installs and configures openssh-server, manages configuration and service by
default and optionally hostkeys.

### Parser Functions

#### ssh_keygen

The module includes a parser function ssh_keygen which can create and cache
ssh keys on the server. Its used internally by the module if the module is
configured to manage the hostkey.

### ssh_sign_certificate

A parser function which allows signing ssh certificates and caching them on
the puppetmaster. It requires to generate a signing key which needs to stay
on the puppetmaster and owned by the user running the puppetmaster.

## Reference

The module contains the following public clases:

- ssh::client
- ssh::server

The following classes are currently not meant to be used directly, but used
by the ssh::server class (depending on the parameters given).

- ssh::known_hosts
- ssh::known_hosts::storeconfig
- ssh::hostkey

## Limitations

This module has been tested and is used primarily on Debian-based systems.
Other systems are supported but cannot be guaranted.

## Development

I happily accept bug reports and pull requests via github.

## Contributors

This module is written and being maintained by

    Patrick Schoenfeld <patrick.schoenfeld@credativ.de>.

It has been based on the module credativ/puppet-ssh-hiera, previously written
for my employer and maintained together with my colleagues. It contains
contributions from at least the following authors:

- Damian Lukowski
- Arnd Hannemann
- Alexander Wirt
- Tomas Barton
- Simon Page
