feo-redmine
-----------

**Version 5.0.0** - Compatible with Puppet 8.x

This module installs redmine, running behind apache and passenger, and backed
by mysql, mariadb or postgresql. Supports both local and remote databases.
Redmine can be installed using git, svn or wget. Only git is tested in the most
recent module versions.

This module is tested on Ubuntu 22.04, Debian 12/13 and Red Hat 8/9 clones
(Almalinux, Rocky Linux, CentOS) with postgresql backend.

The code is based on the abandoned [johanek-redmine](https://github.com/johanek/johanek-redmine)
module and was previously maintained as `puppetfinland-redmine`. Now maintained by FEO.

Requirements
------------

**Puppet 8.x** (>= 8.0.0 < 9.0.0)

**Required modules:**
* puppetlabs/apache >= 13.0.0 < 14.0.0
* puppetlabs/concat >= 9.0.0 < 10.0.0
* puppetlabs/stdlib >= 9.0.0 < 10.0.0
* puppetlabs/vcsrepo >= 7.0.0 < 8.0.0
* puppet/epel >= 5.0.0 < 6.0.0
* tohuwabohu/patch >= 1.0.0 < 3.0.0

**Optional modules (install based on your database):**
* puppetlabs/mysql >= 16.0.0 < 17.0.0 (for MySQL/MariaDB)
* puppetlabs/postgresql >= 10.0.0 < 11.0.0 (for PostgreSQL)

**RedHat derivatives:**
* EPEL yum repository needs to be configured (handled by puppet/epel module)

Example Usage
-------------

### Local Database

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

### External Database

To install redmine with an external MySQL/MariaDB server:

**IMPORTANT:** When using external database (`database_server != 'localhost'`),
the database and user MUST be created manually before running Puppet.
The module only manages database when `database_server` is `'localhost'`.

```puppet
class { 'apache':
  purge_configs => true,
  default_vhost => false,
}

class { 'apache::mod::passenger': }

class { 'redmine':
  version              => '5.0.5',
  database_adapter     => 'mysql2',         # Use 'mysql2' for MySQL/MariaDB, 'postgresql' for PostgreSQL
  database_server      => 'mysql.example.com',
  database_user        => 'redmine_user',
  database_password    => 'secret',
  production_database  => 'redmine_prod',
  development_database => 'redmine_dev',
  install_dir          => '/opt/redmine',
  vhost_priority       => '10',             # Lower priority = loaded first (optional)
}
```

**Note:** To make Redmine act as the default/catch-all vhost (answering all requests not matched by other vhosts):
1. Set `vhost_priority => '10'` to load Redmine vhost first
2. Disable Apache's default vhost with `class { 'apache': default_vhost => false }`
3. This makes Redmine the first vhost loaded, functioning as the default

Installing Plugins
------------------

Plugins can be installed and configured via the redmine::plugin resource. For example, a simple
plugin can be installed like this:

```puppet
    redmine::plugin { 'redmine_plugin':
      source => 'git://example.com/redmine_plugin.git',
      ensure => 'present',  # or 'latest' or 'absent'
    }
```
Plugins can be installed via git (the default) or any other version control system.

Bundle updates and database migrations will be handled automatically. You can update your plugin by
setting `ensure => 'latest'` or directly specifying the version. More complex updates can be done by subscribing
to the plugin resource (via `subscribe => Redmine::Plugin['yourplugin']`)

Uninstalling plugins can be done by simply setting `ensure => 'absent'`. Again, database migration and
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
