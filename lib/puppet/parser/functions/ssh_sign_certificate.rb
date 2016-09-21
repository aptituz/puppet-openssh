
require 'fileutils'

module Puppet::Parser::Functions
  newfunction(:ssh_sign_certificate, :type => :rvalue) do |args|
    raise ArgumentError, ("ssh_sign_certificate(): wrong number of arguments (#{args.length}; must be >= 2)") if args.length < 2

    signkey_file    = args[0]
    certificate_id  = args[1]
    public_key      = args[2]
    options         = args[3] || {}

    unless File.exists?(signkey_file)
        raise ArgumentError, ("ssh_sign_certificate(): first argument (#{signkey_file}) needs to specify path to an existing signing key")
    end

    unless certificate_id.kind_of?(String)
        raise ArgumentError, ("ssh_sign_certificate(): second argument needs to be the certificate id")
    end

    unless public_key.kind_of?(String)
        raise ArgumentError, ("ssh_sign_certificate(): third argument needs to be a string containing public key")
    end

    confdir     = Puppet[:confdir]
    vardir      = Puppet[:vardir]

    # used for caching generated certificates
    cache_dir   = File.join(vardir, 'ssh', 'certificates')
    FileUtils.mkdir_p(cache_dir)

    fqdn        = lookupvar('fqdn')
    cache_file  = File.join(cache_dir, fqdn)

    unless File.exists?(cache_file)
        Dir.mktmpdir("puppet-") do |tmpdir|
            # need to write to temporary file, so that ssh-keygen can access it
            public_key_temp_file    = File.join(tmpdir, "result.pub")
            certificate_temp_file   = File.join(tmpdir, "result-cert.pub")

            File.open(public_key_temp_file, "w") do |file|
                file.write(public_key)
            end

            keygen_command = [ 'ssh-keygen', '-q', '-s', signkey_file, '-I', certificate_id ]
            keygen_command << public_key_temp_file

            IO.popen(keygen_command) do |io|#, :err=>[:child, :out]) do |io|
                #FIXME: Implement error handling
                io.read
            end

            FileUtils.cp(certificate_temp_file, cache_file)
        end
    end

    return File.read(cache_file)
  end
end
