require 'serverspec'

set :backend, :exec

if os[:family] == 'redhat'
  apacheservice = 'httpd'
elsif ['debian', 'ubuntu'].include?(os[:family])
  apacheservice = 'apache2'
end

describe service(apacheservice) do
  it { is_expected.to be_running }
end

describe port(80) do
  it { is_expected.to be_listening }
end

describe service('mysqld') do
  it { is_expected.to be_running }
end

describe command('wget http://localhost') do
  its(:exit_status) { is_expected.to eq 0 }
end

describe command('passenger-status') do
  its(:exit_status) { is_expected.to eq 0 }
  its(:stdout) { is_expected.to match(%r{redmine}) }
end
