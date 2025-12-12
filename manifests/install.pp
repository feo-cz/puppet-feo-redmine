# Class redmine::install
class redmine::install {
  # Install dependencies
  $generic_packages = ['make', 'gcc']

  # MySQL client library: Debian 12+ uses default-libmysqlclient-dev (MariaDB-based)
  $mysql_client_dev = $facts['os']['release']['major'] ? {
    '13'    => 'default-libmysqlclient-dev',  # Debian 13 (Trixie)
    '12'    => 'default-libmysqlclient-dev',  # Debian 12 (Bookworm)
    default => 'libmysqlclient-dev',          # Debian 11 and older
  }

  $debian_packages  = ['libmysql++-dev', $mysql_client_dev, 'libmagickcore-dev', 'libmagickwand-dev', 'ruby-dev', 'libpq-dev',
  'imagemagick', 'libyaml-dev']
  $redhat_packages  = ['postgresql-devel', 'sqlite-devel', 'ImageMagick-devel', 'ruby-devel', 'mariadb-devel']

  case $facts['os']['family'] {
    'Debian':   {
      $packages = concat($generic_packages, $debian_packages)
      $packages_require = undef
    }
    'RedHat':   {
      $packages = concat($generic_packages, $redhat_packages)

      if $facts['os']['name'] == 'CentOS' {
        # Required for ImageMagick-devel dependencies
        file_line { 'CentOS-Powertools-enabled':
          path  => '/etc/yum.repos.d/CentOS-PowerTools.repo',
          line  => 'enabled=1',
          match => '^enabled=(0|1)$',
        }

        $packages_require = File_line['CentOS-Powertools-enabled']
      } else {
        $packages_require = undef
      }
    }
    default:    { $packages = concat($generic_packages, $redhat_packages) }
  }

  ensure_packages($packages, { 'require' => $packages_require })

  # Install bundler
  case $facts['os']['family'] {
    'Debian': {
      # On Debian/Ubuntu, prefer system package for better integration
      ensure_packages(['ruby-bundler'])
      $bundler_require = Package['ruby-bundler']
    }
    default: {
      # On RedHat and others, use gem
      package { 'bundler':
        ensure   => present,
        provider => gem,
      }
      $bundler_require = Package['bundler']
    }
  }

  case $redmine::database_adapter {
    'postgresql' : {
      $without_gems = 'development test sqlite mysql'
    }
    default: {
      $without_gems = 'development test sqlite postgresql'
    }
  }

  Exec {
    cwd  => '/usr/src',
    path => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/'],
  }

  exec { 'bundle_redmine':
    command => "${redmine::bundle} install --gemfile ${redmine::install_dir}/Gemfile --without ${without_gems}",
    creates => "${redmine::install_dir}/Gemfile.lock",
    require => [$bundler_require, Package['make'], Package['gcc'], Package[$packages]],
    notify  => Exec['rails_migrations'],
  }

  create_resources('redmine::plugin', $redmine::plugins)

  if $redmine::provider != 'wget' {
    exec { 'bundle_update':
      cwd         => $redmine::install_dir,
      command     => "${redmine::bundle} update",
      refreshonly => true,
      subscribe   => Vcsrepo['redmine_source'],
      notify      => Exec['rails_migrations'],
      require     => Exec['bundle_redmine'],
    }
  }
}
