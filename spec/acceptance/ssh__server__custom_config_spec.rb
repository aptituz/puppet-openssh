require 'spec_helper_acceptance'

describe 'ssh::server::custom_config' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOT
  include ssh::server
  ssh::server::custom_config { 'allow_users':
    content => 'AllowUsers foo bar baz'
  }
  EOT
     
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe file('/etc/ssh/sshd_config') do
    it { should be_file}
    describe "contains base config" do
      it { should contain '# MANAGED BY PUPPET' }
      it { should contain 'ListenAddress 0.0.0.0' }
    end

    describe "also contains custom config" do
      it { should contain 'AllowUsers foo bar baz' }
    end
  end
end