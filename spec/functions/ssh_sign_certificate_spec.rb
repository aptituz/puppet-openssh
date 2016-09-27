require 'spec_helper'

require 'sshkey'
require 'fileutils'


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
    let (:cache_dir)    { File.join(@tempdir, 'certificates') }


    context "test for expected exceptions" do
        it "raises expected error with no arguments" do
            should run.with_params().and_raise_error(ArgumentError, /wrong number of arguments/)
        end
        it "raises expected error with non-existing key" do
            should run.with_params('/tmp/asdjadj', '', '').and_raise_error(ArgumentError, /owned by us/)
        end
        it "raises expected error with invalid certicate id" do
            should run.with_params(@ca_key_file, nil, '').and_raise_error(ArgumentError, /needs to be a certificate id/)
        end
        it "raises expected error with invalid public key" do
            should run.with_params(@ca_key_file, "foo", '').and_raise_error(ArgumentError, /expected public key as string argument/)
        end
    end

    context "with minimum required params" do
        let (:public_key)   { SSHKey.generate().ssh_public_key }
        let (:params)       { [ @ca_key_file, 'test1', public_key, { 'cache_dir' => cache_dir} ] }

        it { is_expected.to run.with_params(@ca_key_file, 'test1', public_key).and_return(/[a-f0-9]+/) }
        it "returns a certificate" do
            key = subject.call(params)
            expect(certificate_data(key)[:type]).to match(/ssh-(.*)-cert/)
        end
        it "creates certificate directory" do
            subject.call(params)
            expect(Dir).to exist(cache_dir)#).to eq(true)
        end
    end

    context "with existing directory" do
        let (:public_key)   { SSHKey.generate().ssh_public_key }
        let (:params)       { [ @ca_key_file, 'test1', public_key, { 'cache_dir' => cache_dir} ] }

        it "works without complaining" do
            FileUtils::mkdir_p(cache_dir)
            expect(Dir).to exist(cache_dir)
            is_expected.to run.with_params(@ca_key_file, 'test1', public_key).and_return(/[a-f0-9]+/)
        end
    end

    context "with params for a host certificate" do
        let (:public_key)   { SSHKey.generate().ssh_public_key }
        let (:params)       { [ @ca_key_file, 'test1', public_key, { 'host_certificate' => true} ] }

        it { is_expected.to run.with_params(@ca_key_file, 'test1', public_key).and_return(/[a-f0-9]+/) }
        describe "returns a certificate" do
            let (:key) { subject.call(params) }
            # certfile = File.join(@tempdir, "cert_out")
            # File.open(certfile, "w") { |f| f.write(key) }
            # output = %x[ssh-keygen -L -f #{certfile}]
            # certificate_data = parse_keygen_list_output(output)
            # expect($?.exitstatus).to eq(0)
            it "which is a host certificate" do
                expect(certificate_data(key)[:type]).to match(/host certificate/)
            end

            it "which is valid forever" do
                expect(certificate_data(key)[:valid]).to eq('forever')
            end
        end
    end
    context "with invalid options" do
        let (:options) { { 'invalid' => nil } }
        let (:params)  { [ @ca_key_file, 'test1', public_key, options ] }

        it { is_expected.to run.with_params(@ca_key_file, 'test1', 'public_key', options).and_raise_error(ArgumentError) }

    end

    context "with some options" do
        let (:public_key)   { SSHKey.generate().ssh_public_key }
        let (:principals)   { ['foo', 'baz'] }
        let (:options)      {{
            'principals'    => principals,
            'validity'      => '+7d',
            'serial_number' => '123',
            'cert_options'  => ['clear','permit-port-forwarding'],
        }}
        let (:params)       { [ @ca_key_file, 'test1', public_key, options ] }


        describe "generates a certificate" do
            let (:key) { subject.call(params) }
            it "which is a user certificate" do
                expect(certificate_data(key)[:type]).to match(/user certificate/)
            end

            it "having defined principals" do
                expect(certificate_data(key)[:principals]).to match_array(principals)
            end


            it "being valid for 7 days" do
                validity = certificate_data(key)[:valid]
                expect(validity[:to] - validity[:from]).to eq(7)
            end

            it "has the expected serial number" do
                expect(certificate_data(key)[:serial]).to eq(123)
            end
            it "has the expected options" do
                expect(certificate_data(key)[:extensions]).to eq(['permit-port-forwarding'])
            end
        end
    end

    context "with false for a boolean param" do
        let (:public_key)   { SSHKey.generate().ssh_public_key }
        let (:params)       { [ @ca_key_file, 'test1', public_key, { 'host_certificate' => false} ] }
        let (:key)          { subject.call(params) }

        it "returns a user  is a user certificate" do
            expect(certificate_data(key)[:type]).to match(/user certificate/)
        end
    end

end
