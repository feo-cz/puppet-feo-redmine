puppetfinland-redmine
---------------------

This module installs redmine, running behind apache and passenger, and backed
by mysql, mariadb or postgresql. Supports both local and remote databases.
Redmine can be installed using git, svn or wget. Only git is tested in the most
recent module versions.

The current incarnation of this module is tested on Ubuntu 22.04 and Red Hat 9
clones (Almalinux) with postgresql backend. Older versions of this module are
known to work on CentOS 8 as well.

The code is based on the abandoned
[johanek-redmine](https://github.com/johanek/johanek-redmine) module.

Requirements
------------

Required modules:
* puppetlabs-mysql
* puppetlabs-stdlib
* puppetlabs-apache
* puppetlabs-concat
* puppetlabs-postgresql

Optional modules:
* puppetlabs-vcsrepo if you want to download redmine from a repository (the default)

RedHat derivatives:
* EPEL yum repository needs to be configured

Example Usage
-------------

To install redmine that uses local postgresql database:

```puppet
class { 'apache':
  purge_configs => true,
  default_vhost => false,
}

class { 'apache::mod::passenger': }

class { 'postgresql::server': }

class { 'redmine':
  version           => '5.0.5',
  database_password => 'secret',
  database_adapter  => 'postgresql',
  install_dir       => '/opt/redmine',
}
```

Installing Plugins
------------------

Plugins can be installed and configured via the redmine::plugin resource. For example, a simple
plugin can be installed like this:

```puppet
    redmine::plugin { 'redmine_plugin'
      source => 'git://example.com/redmine_plugin.git'
    }
```
Plugins can be installed via git (the default) or any other version control system.

Bundle updates and database migrations will be handled automatically. You can update your plugin by
setting `ensure => latest` or directly specifying the version. More complex updates can be done by subscribing
to the plugin resource (via `subscribe => Redmine::Plugin['yourplugin']`)

Uninstalling plugins can be done by simply setting `ensure => absent`. Again, database migration and
deletion are done for you.

Developing module code in AWS with Ansible
------------------------------------------

You can use the provided ansible-aws-provision too to provision disposable
Redmine instances. See
[ansible-aws-provision/README.md](ansible-aws-provision/README.md) for usage
details. A sample AWS config file is provided, see
[aap-site.yml.sample](aap-site.yml.sample).

Contributing
------------

See the wiki for further information about contributing to this module: https://github.com/johanek/johanek-redmine/wiki
