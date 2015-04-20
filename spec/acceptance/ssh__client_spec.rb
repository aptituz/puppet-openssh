require 'spec_helper_acceptance'

describe 'ssh::client' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include ssh::client
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe package('openssh-client') do
    it { should be_installed }
  end

#FIXME: How can I run tests against Debian AND Centos?
#  describe package('openssh-clients') do
#    it { should be_installed }
#  end

end
