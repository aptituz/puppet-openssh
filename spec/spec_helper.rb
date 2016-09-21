require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end

# yeah, i know: parsing ssh-keygen -L output might not be totally
# reliable, but this is just a test and I currently don't have
# a lib for ssh certificate parsing around. once this exists
# this code can be replaced
def certificate_data(certificate_data)
    result = Hash.new

    output = nil
    Dir.mktmpdir("rspec-") do |path|
        file = File.join(path, "cert_test")
        File.open(file, "w") do |f|
            f.write(certificate_data)
        end
        output = %x[ssh-keygen -L -f #{file}]
    end

    current_field = nil
    # if you've never seen inject, this might need explanation:
    # inject loops over a collection, while memorizing whatever the last
    # run returned, which is a field we've found in the output
    output.split("\n").inject do |memo,line|
        line.strip!

        # Type: ssh-rsa-cert-v01@openssh.com user certificate
        if match = line.match(/([\w ]+:) (.*)$/)
            current_field = match[1].downcase.gsub(' ', '_')
            data          = match[2]

            unless data.empty?
                result[current_field.chop.to_sym] = data
            end
        # Extensions:
        elsif line.end_with?(':')
            # fields with multiple values start with their key on a single line and keys
            # following on the next lines, so just track the current_field and let
            # the next iterations slurp the data
            current_field = line.downcase.gsub(' ', '_')
        elsif line.downcase != current_field
            result[current_field.chop.to_sym] ||= []
            result[current_field.chop.to_sym] << line
        end

        current_field
    end

    if result.has_key?(:valid) and match = result[:valid].match(/from (.*) to (.*)$/)
        result[:valid] = { :from => Date.parse(match[1]), :to => Date.parse(match[2]) }
    end

    result[:serial] = result[:serial].to_i if result.has_key?(:serial)
    result
end
