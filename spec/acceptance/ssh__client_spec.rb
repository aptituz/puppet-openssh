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
end
