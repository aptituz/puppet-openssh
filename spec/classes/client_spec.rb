require 'spec_helper'

describe 'ssh::client' do
    let (:facts) {{
        :osfamily   => 'Debian'
    }}
	it { should compile.with_all_deps }

	context "basic tests" do
		it { should contain_class('ssh::client') }
		it { should contain_package('openssh-client').with( :ensure => 'present' ) }
	end

	context "absence test" do
		let (:params) { { :ensure => 'absent' } }
		it { should contain_package('openssh-client').with( :ensure => 'absent' ) }
	end

    context "RedHat specific differences" do
        let (:facts) {{
            :osfamily   => 'RedHat'
        }}

        it { should contain_package('openssh-clients').with( :ensure => 'present' ) }        
    end
end
