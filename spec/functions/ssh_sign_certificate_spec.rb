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

    context "with minimum required params" do
        let (:public_key)   { SSHKey.generate().ssh_public_key }
        let (:params)       { [ @ca_key_file, 'test1', public_key ] }

        it { is_expected.to run.with_params(@ca_key_file, 'test1', public_key).and_return(/[a-f0-9]+/) }
        it "returns a certificate" do
            key = subject.call(params)
            expect(certificate_data(key)[:type]).to match(/ssh-(.*)-cert/)
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
end
