# Change log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [3.0.0]
### Summary:


### Changes
* New parameter $additional_known_hosts which allows to specify
  arbitrary known hosts entries to be included in global known hosts
  file.

* Obsoletion: The storeconfig class has been removed from this version,
  since it's way too troublesome in a component module.

* Feature: Introduction of ssh::certificate define and the compagnion
  parser function ssh_sign_certificate. This allows signing certificates
  with a pre-generated SSHCA key. It's also possible to pass the path to
  an ca key to ssh::server which will make the module generate and
  configure a host certificate for itself.

* The parameter hostaliases now has to be an array. This change is because
  it actually is a list of values and although it was used solely for
  a hostkey (were it is needed as a comma-separated string) it is now
  used for certificates, too, where it has to be an array.

## [2.4.0]
### Summary:

Mostly a maintenance release with some bugfixes provided by the community
(thank you!) and one new feature: Added support for custom config fragments.

This is probably the last non-breaking release, since I'm going to prepare
for future parser soon and might make use of the new features.

### Changes:

* Feature: Add support for custom config fragments: Which builds sshd_config from some concat resources
  and adds the ssh::server::custom_config resource.
* Feature: Module now passes the hostaliases parameter to the storeconfig class (if this is used) instead
  of using a hardcoded list of facts. The old way is still supported when hostaliases are not defined
  but will soon be obsolete.
* Bugfix for listen_address and permit_root_login for PE 2015.2 and CentOS 7
* Bugfix for non working manage_known_hosts switch
* Template fixes and added support for cipher setting
* Several changes to the build support files, including update to a new puppet-lint version.
