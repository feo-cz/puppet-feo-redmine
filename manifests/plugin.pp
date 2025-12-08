# @summary install a Redmine plugin
#
# @param ensure
#  Whether the plugin should be installed.
# @param source
#  Repository of the plugin.
# @param version
#  Set to desired version.
# @param provider
#  The vcs provider. Default: git
#
define redmine::plugin (
  Enum['installed', 'latest', 'absent'] $ensure   = present,
  Optional[String]                      $source   = undef,
  Optional[String]                      $version  = undef,
  Enum['git','svn']                     $provider = 'git',
) {
  $install_dir = "${redmine::install_dir}/plugins/${name}"
  if $ensure == absent {
    exec { "rake redmine:plugins:migrate NAME=${name} VERSION=0":
      notify      => Class['apache::service'],
      path        => ['/bin','/usr/bin', '/usr/local/bin'],
      environment => ['HOME=/root','RAILS_ENV=production','REDMINE_LANG=en'],
      provider    => 'shell',
      cwd         => $redmine::install_dir,
      before      => Vcsrepo[$install_dir],
      require     => Exec['bundle_update'],
      onlyif      => "test -d ${install_dir}",
    }
    $notify = undef
  } else {
    $notify = Exec['bundle_update']
  }

  if $source == undef {
    fail("no source specified for redmine plugin '${name}'")
  }

  case $provider {
    'svn' : {
      $provider_package = 'subversion'
    }
    'hg': {
      $provider_package = 'mercurial'
    }
    default: {
      $provider_package = $provider
    }
  }
  ensure_packages($provider_package)

  vcsrepo { $install_dir:
    ensure   => $ensure,
    revision => $version,
    source   => $source,
    provider => $provider,
    notify   => $notify,
    require  => [Package[$provider_package]
    , Exec['bundle_redmine']],
  }
}
