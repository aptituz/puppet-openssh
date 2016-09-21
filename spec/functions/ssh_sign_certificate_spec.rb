require 'spec_helper'

require 'sshkey'


describe 'ssh_sign_certificate' do
    before :each do
        @tempdir        = Dir.mktmpdir("rspec-")
        @ca_key         = SSHKey.generate()
        @ca_key_file    = File.join(@tempdir, "id_ca")
        File.open(@ca_key_file, "w", 0600) do |file|
            file.write(@ca_key.private_key)
        end

    end

    let (:tempdir) { @tempdir }

    context "with required params" do
        let (:public_key)   { SSHKey.generate().ssh_public_key }
        let (:params)       { [ @ca_key_file, 'test1', public_key ] }

        it { is_expected.to run.with_params(@ca_key_file, 'test1', public_key).and_return(/[a-f0-9]+/) }
        it "returns a certificate" do
            key = subject.call(params)
            certfile = File.join(@tempdir, "cert_out")
            File.open(certfile, "w") { |f| f.write(key) }
            %x[ssh-keygen -L -f #{certfile}]
            expect($?.exitstatus).to eq(0)
        end
    end

end
