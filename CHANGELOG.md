# Change log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

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
