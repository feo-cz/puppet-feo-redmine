# require 'spec_helper'

# describe 'redmine::plugin', type: :define do
#   let :facts do
#     {
#       osfamily: 'Redhat',
#       operatingsystemrelease: '6',
#       operatingsystemmajrelease: '6',
#       domain: 'test.com',
#       concat_basedir: '/dne'
#     }
#   end
#
#   let :pre_condition do
#     'class { "redmine": install_dir => "/opt/redmine" }'
#   end
#
#   let(:title) { 'test_plugin' }
#
#   context 'no parameters' do
#     it 'raises an error when the source is not present' do
#       expect { is_expected.to compile }.to raise_error(%r{source})
#     end
#   end
#
#   context 'plugin install' do
#     let :params do
#       {
#         source: 'git://example.git',
#         version: '1.2.3'
#       }
#     end
#
#     it {
#       is_expected.to contain_vcsrepo('/opt/redmine/plugins/test_plugin').with(
#       'revision' => '1.2.3',
#       'provider' => 'git',
#       'source'   => 'git://example.git',
#       'notify'   => 'Exec[bundle_update]',
#     )
#     }
#   end
#
#   context 'plugin uninstall' do
#     let :params do
#       {
#         ensure: 'absent',
#         source: 'git://example.git'
#       }
#     end
#
#     it {
#       is_expected.to contain_exec('rake redmine:plugins:migrate NAME=test_plugin VERSION=0').with(
#       'cwd'    => '/opt/redmine',
#       'before' => 'Vcsrepo[/opt/redmine/plugins/test_plugin]',
#       'onlyif' => 'test -d /opt/redmine/plugins/test_plugin',
#     )
#     }
#
#     it {
#       is_expected.to contain_vcsrepo('/opt/redmine/plugins/test_plugin').with(
#       'ensure' => 'absent',
#     )
#     }
#   end
#
#   context 'provider svn' do
#     let :params do
#       {
#         source: 'git://example.git',
#         provider: 'svn'
#       }
#     end
#
#     it { is_expected.to contain_package('subversion') }
#     it { is_expected.to contain_vcsrepo('/opt/redmine/plugins/test_plugin').that_requires('Package[subversion]') }
#   end
# end
