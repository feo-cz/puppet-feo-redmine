## 5.0.0 (2025-12-08)

### BREAKING CHANGES
- **Puppet 8.x required**: Minimum Puppet version is now 8.0.0
- **Module renamed**: Changed from `puppetfinland-redmine` to `feo-redmine`
- **Author changed**: Now maintained by FEO
- **Major dependency upgrades**: All module dependencies upgraded to Puppet 8 compatible versions
- **Optional dependencies**: MySQL and PostgreSQL are now optional dependencies (install only what you need)
- **Removed deprecated functions**: Removed `validate_string()` from plugin manifest

### Features
- Support for Puppet 8.x (>= 8.0.0 < 9.0.0)
- Added Debian 12 and 13 support
- MySQL module is now optional (>= 16.0.0 < 17.0.0) - install only if using MySQL
- PostgreSQL module is now optional (>= 10.0.0 < 11.0.0) - install only if using PostgreSQL

### Dependencies Updated
**Required dependencies:**
- puppetlabs/apache: 9.x → 13.x (>= 13.0.0 < 14.0.0)
- puppetlabs/concat: 8.x → 9.x (>= 9.0.0 < 10.0.0)
- puppet/epel: 4.x → 5.x (>= 5.0.0 < 6.0.0)
- puppetlabs/stdlib: 8.x → 9.x (>= 9.0.0 < 10.0.0)
- puppetlabs/vcsrepo: 6.x → 7.x (>= 7.0.0 < 8.0.0)
- tohuwabohu/patch: expanded range to >= 1.0.0 < 3.0.0

**Optional dependencies (install based on your database):**
- puppetlabs/mysql: 14.x → 16.x (>= 16.0.0 < 17.0.0)
- puppetlabs/postgresql: 9.x → 10.x (>= 10.0.0 < 11.0.0)

### Code Quality
- Removed deprecated `validate_string()` function from manifests/plugin.pp:38
- Fixed type declaration: Changed `String $version = undef` to `Optional[String] $version = undef` in manifests/init.pp:75
- Uses native Puppet type checking instead of stdlib validation functions
- All manifests use modern `$facts['key']` syntax (no legacy facts)
- Hiera 5 configuration (already compatible with Puppet 8)
- All manifests verified for Puppet 8 strict mode compatibility

### Migration Guide
See UPGRADE.md for detailed upgrade instructions from version 4.1.0 to 5.0.0

##2.3.0
WARNING: With the next major version (3.0.0) we will up the default redmine version.
Check if you can upgrade to 2.6.x or explicitly set your version.
Now passenger starts redmine on apache start. This removes the delay the first
visitor experiences after a restart of the webserver.

###Features
- Start a passenger worker for redmine when apache starts

##2.2.0

###Notes
This version improves the experience for users who just want to get redmine working
out of the box without much configuration.
For those of you who already have a vhost set up and want to get redmine running in
a subdirectory, we have a new `www_subdir` setting.
Ubuntu 10.04 support has been dropped because it has been deemed too old.

###Features
- Option to install redmine in a directory relative to the webroot
- CentOS support

###Bugfixes
- Set the webroot correctly on non Redhat based systems
- Added note on requiring EPEL
- Log file rotation now uses the install dir and not the symlink

##2.1.0

###Notes
You can now manage your redmine plugins with the newly added `redmine::plugin` type. All
standard actions such as installing, updating and removing are supported.
This release deprecates wget. It will be removed in the next major version. Please use a
version control system like git instead.

###Features
- Deprecate wget provider
- Added support for plugins
- Ubuntu 14.04 (trusty) support

###Bugfixes
- Specify gem versions for tests
- Fix unbound dependency versions
- Fixes to the wget provider
- Fix evaluation error in Puppet 4

##2.0.0

###Features
- Automaticially install the correct VCS provider
- Detect ruby version and set database adapter accordingly

##1.2.1

###Features
- Improved Metadata quality

##1.2.0

###Notes
This release fixes some dependency races that could occur because some requires where missing.
Additionally, postgresql can now be selected as the database adapter.

###Features
- Postgresql support

###Bugfixes
- Require all packages before doing install
- Fix MySQL dependency order

##1.1.0

###Features
- Added debian support
- Custom configuration options
- Add ImageMagick to debian

##1.0.1

###Bugfixes
- Fixed whitespace in documentation

##1.0.0

###Notes
With rubyforge no longer available, the module now downloads redmine from the official repos
or from a user provided url.

###Features
- Added VCS support
- Git is now the default provider
- Added download url to the options
- Added metadata.json
- Tests now include linting and syntax checking
- Run redmine updates
- Support for mariadb

###Bugfixes
- Removed deletion of the default apache site
- Fix dependencies for debian
- Fix file permissions
