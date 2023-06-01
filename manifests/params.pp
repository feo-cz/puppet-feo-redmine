# Class redmine::params
class redmine::params {
  if $redmine::database_adapter {
    $real_adapter = $redmine::database_adapter
  } elsif versioncmp($facts['ruby']['version'], '1.9') >= 0 {
    $real_adapter = 'mysql2'
  } else {
    $real_adapter = 'mysql'
  }

  if $redmine::version {
    $version = $redmine::version
  } else {
    $version = '4.1.1'
  }

  case $redmine::provider {
    'svn' : {
      $provider_package = 'subversion'
    }
    'hg': {
      $provider_package = 'mercurial'
    }
    default: {
      $provider_package = $redmine::provider
    }
  }
}
