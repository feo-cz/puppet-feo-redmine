# @summary Install  redmine, running behind apache and passenger and backed by eiter mysql or maria-db
#
#
# @param version
#   Set to desired version.
# @param download_url
#   Download URL for redmine tar.gz when using wget as the provider.
#   The repository url otherwise.
#   When using wget, be sure to provide the full url.
#   Default: https://github.com/redmine/redmine
#  @param provider
#   The VCS provider or wget.
#   When setting the provider to wget, be sure to set download_url
#   to a valid tar.gz archive.
#   To use the svn provider you have to provide the full url to the
#   tag or branch you want to download and unset the version.
# @param database_server
#   Database server to use.
#   If server is not on localhost, the database and user must
#   be setup in advance.
# @param database_user
#   Database user.
# @param database_password
#   Database user password.
# @param production_database
#   Name of database to use for production environment.
# @param development_database
#   Name of database to use for development environment.
#   NOTE: This is NEVER used in production (RAILS_ENV=production) but required
#   in database.yml. For production servers, set this to the same value as
#   production_database to avoid creating an unused database.
# @param database_adapter
#   Database adapter to use for database configuration.
#   Can be either 'mysql' for ruby 1.8, 'mysql2' for ruby 1.9 or 'postgresql'.
# @param email_delivery_method
#   The method Redmine uses to deliver email.
# @param smtp_server
#   SMTP server to use.
# @param smtp_domain
#   Domain to send emails from.
# @param smtp_port
#   SMTP port to use.
# @param smtp_authentication
#   SMTP authentication mode.
# @param smtp_username
#   SMTP user name for authentication.
# @param smtp_password
#   SMTP password for authentication.
# @param smtp_ssl
#   Use SSL with SMTP.
# @param webroot
#   Directory in which redmine web files will be installed (symlink to install_dir).
#   Default: /var/www/redmine
# @param install_dir
#   Path where redmine will be installed
# @param vhost_aliases
#   Server aliases to use in the vhost config.
# @param vhost_servername
#   Server name to use in the vhost config..
# @param vhost_port
#   Port for Apache vhost to listen on. Default: 80
# @param override_options
#   Extra options to add to configuration.yml.
# @param plugins
#   Optional hash of plugins, which are passed to redmine::plugin via create_resources.
#   Example: { 'plugin_name' => { 'source' => 'git://...', 'version' => '1.0' } }
# @param www_subdir
#   Optional directory relative to the site webroot to install redmine in.
#   Undef by default. Expects a path string without leading slash.
#   When using this option the vhost config is your responsibility.
# @param create_vhost
#   Enable or disable vhost creation.
#   When disabling this option the vhost config is your responsibility.
# @param bundle
#   Name of the "bundle" executable to use to set up redmine. The default
#   value depends on the operating system.
#
class redmine (
  String                   $bundle,
  Optional[String]         $version               = undef,
  Stdlib::HTTPUrl          $download_url          = 'https://github.com/redmine/redmine',
  String                   $database_server       = 'localhost',
  String                   $database_user         = 'redmine',
  String                   $database_password     = 'redmine',
  String                   $production_database   = 'redmine',
  String                   $development_database  = 'redmine_development',
  Optional[Enum['mysql','mysql2','postgresql']] $database_adapter = undef,
  Enum['sendmail','smtp']  $email_delivery_method = 'smtp',
  Stdlib::Host             $smtp_server           = 'localhost',
  String                   $smtp_domain           = $facts['networking']['domain'],
  Stdlib::Port             $smtp_port             = 25,
  Boolean                  $smtp_authentication   = false,
  Optional[String]         $smtp_username         = undef,
  Optional[String]         $smtp_password         = undef,
  Boolean                  $smtp_ssl              = false,
  String                   $vhost_aliases         = 'redmine',
  String                   $vhost_servername      = 'redmine',
  Stdlib::Port             $vhost_port            = 80,
  Stdlib::Unixpath         $webroot               = '/var/www/redmine',
  Stdlib::Unixpath         $install_dir           = '/usr/src/redmine',
  Enum['wget','git','svn'] $provider              = 'git',
  Hash[String, String]     $override_options      = {},
  Hash                     $plugins               = {},
  Optional[String]         $www_subdir            = undef,
  Boolean                  $create_vhost          = true,

) {
  class { 'redmine::params': }
  -> class { 'redmine::download': }
  -> class { 'redmine::config': }
  -> class { 'redmine::install': }
  -> class { 'redmine::database': }
  -> class { 'redmine::rake': }
}
