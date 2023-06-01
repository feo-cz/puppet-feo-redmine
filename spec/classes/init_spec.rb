require 'spec_helper'

describe 'redmine' do
  on_supported_os.each do |os, os_facts|
    context "reasonable defaults on #{os}" do
      # puppet-postgresql fails if the service_provider fact is not set
      extra_facts = { service_provider: 'systemd' }

      let(:facts) { os_facts.merge(extra_facts) }

      let(:pre_condition) do
        ['class { "apache": purge_configs => true, default_vhost => false, }',
         'class { "apache::mod::passenger": }',
         'class { "postgresql::server": }']
      end
      let(:params) do
        {
          'webroot'          => '/var/www/html',
          'provider'         => 'git',
          'version'          => '5.0.5',
          'database_adapter' => 'postgresql',
        }
      end

      it { is_expected.to compile }
      it { is_expected.to create_class('redmine::config') }
      it { is_expected.to create_class('redmine::download') }
      it { is_expected.to create_class('redmine::install') }
      it { is_expected.to create_class('redmine::database') }
      it { is_expected.to create_class('redmine::rake') }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{adapter: postgresql}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{database: redmine}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{database: redmine_development}) }
      it { is_expected.to contain_file('/var/www/html').with({ 'ensure' => 'link' }) }
      it { is_expected.to contain_apache__vhost('redmine').with({ 'docroot' => '/var/www/html/public' }) }

      if os_facts[:operatingsystem] == 'Ubuntu' && ['22.04'].include?(os_facts[:operatingsystemrelease])
        it { is_expected.to contain_exec('bundle_update').with({ 'command' => 'bundle3.0 update' }) }
      else
        it { is_expected.to contain_exec('bundle_update').with({ 'command' => 'bundle update' }) }
      end
    end

    context "git provider with local postgresql on #{os}" do
      # puppet-postgresql fails if the service_provider fact is not set
      extra_facts = { service_provider: 'systemd' }

      let(:facts) { os_facts.merge(extra_facts) }

      let(:pre_condition) do
        ['class { "apache": purge_configs => true, default_vhost => false, }',
         'class { "apache::mod::passenger": }',
         'class { "postgresql::server": }']
      end
      let(:params) do
        {
          'webroot'              => '/var/www/html',
          'provider'             => 'git',
          'version'              => '5.0.5',
          'database_adapter'     => 'postgresql',
          'database_server'      => 'localhost',
          'database_user'        => 'dbuser',
          'database_password'    => 'password',
          'production_database'  => 'redproddb',
          'development_database' => 'reddevdb'
        }
      end

      it { is_expected.to contain_package('make') }
      it { is_expected.to contain_package('gcc') }
      it {
        is_expected.to contain_vcsrepo('redmine_source').with(
          'revision' => '5.0.5',
          'provider' => 'git',
          'source'   => 'https://github.com/redmine/redmine',
          'path'     => '/usr/src/redmine',
        )
      }

      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{adapter: postgresql}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{database: redproddb}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{database: reddevdb}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{host: localhost}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{username: dbuser}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{password: password}) }

      ['redproddb', 'reddevdb'].each do |db|
        it {
          is_expected.to contain_postgresql__server__db(db).with(
          'encoding' => 'utf8',
          'user'     => 'dbuser',
        )
        }
      end

      it { is_expected.not_to contain_mysql__database('redproddb') }
      it { is_expected.not_to contain_mysql__user('dbuser@localhost') }
      it { is_expected.not_to contain_mysql__grant('dbuser@localhost/redproddb') }
      it { is_expected.not_to contain_mysql__database('reddevdb') }
      it { is_expected.not_to contain_mysql__grant('dbuser@localhost/reddevdb') }
    end

    context "git provider with local mysql on #{os}" do
      let(:facts) { os_facts }

      let(:pre_condition) do
        ['class { "apache": purge_configs => true, default_vhost => false, }',
         'class { "apache::mod::passenger": }',
         'class { "mysql::server": }']
      end
      let(:params) do
        {
          'webroot'              => '/var/www/html',
          'provider'             => 'git',
          'version'              => '5.0.5',
          'database_adapter'     => 'mysql2',
          'database_server'      => 'localhost',
          'database_user'        => 'dbuser',
          'database_password'    => 'password',
          'production_database'  => 'redproddb',
          'development_database' => 'reddevdb'
        }
      end

      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{adapter: mysql2}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{database: redproddb}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{database: reddevdb}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{host: localhost}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{username: dbuser}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{password: password}) }

      ['redproddb', 'reddevdb'].each do |db|
        it {
          is_expected.not_to contain_postgresql__server__db(db).with(
          'encoding' => 'utf8',
          'user'     => 'dbuser',
        )
        }
      end

      it { is_expected.to create_class('redmine::database_mysql') }
      it { is_expected.to contain_mysql_database('redproddb') }
      it { is_expected.to contain_mysql_user('dbuser@localhost') }
      it { is_expected.to contain_mysql_grant('dbuser@localhost/redproddb.*') }
      it { is_expected.to contain_mysql_database('reddevdb') }
      it { is_expected.to contain_mysql_grant('dbuser@localhost/reddevdb.*') }
    end

    context 'remote postgresql db params' do
      # puppet-postgresql fails if the service_provider fact is not set
      extra_facts = { service_provider: 'systemd' }

      let(:facts) { os_facts.merge(extra_facts) }

      let(:pre_condition) do
        ['class { "apache": purge_configs => true, default_vhost => false, }',
         'class { "apache::mod::passenger": }',
         'class { "postgresql::server": }']
      end

      let(:params) do
        {
          'version'              => '5.0.5',
          'provider'             => 'git',
          'database_adapter'     => 'postgresql',
          'database_server'      => 'db1',
          'database_user'        => 'dbuser',
          'database_password'    => 'password',
          'production_database'  => 'redproddb',
          'development_database' => 'reddevdb'
        }
      end

      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml') }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{adapter: postgresql}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{database: redproddb}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{database: reddevdb}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{host: db1}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{username: dbuser}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/database.yml').with_content(%r{password: password}) }
      it { is_expected.not_to contain_postgresql__server__db('redproddb') }
      it { is_expected.not_to contain_postgresql__server__db('reddevdb') }
    end

    context 'wget download' do
      extra_facts = { service_provider: 'systemd' }

      let(:facts) { os_facts.merge(extra_facts) }

      let(:pre_condition) do
        ['class { "apache": purge_configs => true, default_vhost => false, }',
         'class { "apache::mod::passenger": }',
         'class { "postgresql::server": }']
      end

      let(:params) do
        {
          'version'              => '5.0.5',
          'provider'             => 'wget',
          'download_url'         => 'https://example.com/redmine.tar.gz',
          'database_adapter'     => 'postgresql',
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_package('wget') }
      it { is_expected.to contain_package('tar') }
      it {
        is_expected.to contain_exec('redmine_source').with(
          'cwd'     => '/usr/src',
          'path'    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ],
          'command' => 'wget -O redmine.tar.gz https://example.com/redmine.tar.gz',
          'creates' => '/usr/src/redmine.tar.gz',
        )
      }
      it {
        is_expected.to contain_exec('extract_redmine').with(
          'cwd'     => '/usr/src',
          'path'    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ],
          'command' => 'mkdir -p /usr/src/redmine && tar xvzf redmine.tar.gz --strip-components=1 -C /usr/src/redmine',
          'creates' => '/usr/src/redmine',
        )
      }
      it {
        is_expected.to contain_file('/var/www/html/redmine').with(
          'ensure' => 'link',
          'target' => '/usr/src/redmine',
        )
      }
    end

    context 'set override_options' do
      extra_facts = { service_provider: 'systemd' }

      let(:facts) { os_facts.merge(extra_facts) }

      let(:pre_condition) do
        ['class { "apache": purge_configs => true, default_vhost => false, }',
         'class { "apache::mod::passenger": }',
         'class { "postgresql::server": }']
      end

      let :params do
        {
          'version'          => '5.0.5',
          'database_adapter' => 'postgresql',
          # 'webroot'          => '/var/www/html',
          'override_options' => { 'foo' => 'bar', 'additional' => 'options' }
        }
      end

      it { is_expected.to contain_file('/usr/src/redmine/config/configuration.yml').with_content(%r{foo: bar}) }
      it { is_expected.to contain_file('/usr/src/redmine/config/configuration.yml').with_content(%r{additional: options}) }
    end
  end
end
