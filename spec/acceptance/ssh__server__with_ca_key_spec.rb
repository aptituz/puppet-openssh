require 'spec_helper_acceptance'

$ca_key = ''

describe 'ssh::server::custom_config' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      on hosts.first, 'rm -f /tmp/id_ca*'
      on( hosts.first, 'ssh-keygen -f /tmp/id_ca -N ""' )
      pp = <<-EOT
  class { 'ssh::server':
    manage_hostkey  => true,
    ca_key          => '/tmp/id_ca',
    trusted_cert_authorities  => {
      'foo' => 'ABC',
      'bar' => { 'type' => 'ssh-dsa', content => 'baz', 'hostaliases' => '*.mydomain.de' }
    }
  }
  EOT

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
  describe file('/tmp/id_ca') do
    it { should be_file}
  end

  describe file('/etc/ssh/ssh_host_rsa_key-cert.pub') do
    it { should be_file}
    it { should contain 'ssh-rsa-cert-v01@openssh.com' }
  end

  describe file('/etc/ssh/sshd_config') do
    describe "contains HostCertificate config" do
      it { should contain 'HostCertificate /etc/ssh/ssh_host_rsa_key-cert' }
    end
  end

  describe file('/etc/ssh/ssh_known_hosts') do
    describe "contains cert authority line" do
      it { should contain 'cert-authority * ssh-rsa ABC' }
      it { should contain 'cert-authority *.mydomain.de ssh-dsa baz' }

    end
  end
end
