require 'spec_helper_acceptance'

describe 'ssh::server' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = 'include ssh::server'
     
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe package('openssh-server') do
    it { should be_installed}
  end

  describe file('/etc/ssh/sshd_config') do
    it { should be_file}
  end

  describe service('ssh') do
    it { should be_enabled }
    it { should be_running }
  end

  describe 'running puppet code with manage_hostkey => true' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'ssh::server':
          manage_hostkey => true
        }
      EOS
    end
  end

  describe file('/etc/ssh/ssh_host_ecdsa_key') do
    it { should be_file}
  end

  describe file('/etc/ssh/ssh_host_dsa_key') do
    it { should be_file}
  end

  describe file('/etc/ssh/ssh_host_rsa_key') do
    it { should be_file}
  end

end
