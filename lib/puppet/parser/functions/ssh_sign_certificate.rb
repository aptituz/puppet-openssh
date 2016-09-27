
require 'fileutils'

module Puppet::Parser::Functions
  newfunction(:ssh_sign_certificate, :type => :rvalue, :doc => <<-DOC
    This function allows generation and puppetmaster-side caching of SSH certificates,
    for user certificates (default) and host certificates.

    Beneath the required parameters (see below) it can take a hash with some options that
    refer to ssh-keygen arguments. The following shows the supported parameters
    and a brief description. For further information see the ssh-keygen manpage.

    - validity: How long should the certificate be valid (-V)
    - serial_number: What to use as serial number (-z)
    - host_certifcate: Boolean to indicate that you want to generate a host certificate (-h)
    - principals: Array of principals set on the key (-n)
    - cert_options: Array of options to set on the certifiate (e.g. no-tty and alike, refers to -O)

    @param [String] signkey_file    The path (on the puppet master) to a ssh private key used as CA.
    @param [String] certificate_id  An id for the ssh certificate to generate (-I argument to ssh-keygen)
    @param [String] public_key      The public key which shall be signed by the CA.
    @param [Hash]   additional options
    @return [String] the signed certificate
    @example Example usage:
      $public_key  = $::sshrsakey
      $certificate = ssh_sign_certificate('/etc/puppet/id_ca', $::fqdn, $public_key, { host_certificate: true } )

      file { '/etc/ssh/ssh_host_rsa_key-cert.pub':
        ensure  => present,
        content => $certificate
      }

    DOC
    ) do |args|
    raise ArgumentError, ("ssh_sign_certificate(): wrong number of arguments (#{args.length}; must be >= 2)") if args.length < 2

    signkey_file    = args[0]
    certificate_id  = args[1]
    public_key      = args[2]
    options         = args[3] || {}
    valid_options   = {
        'validity'           => ['-V', '%s'],
        'serial_number'      => ['-z', '%s'],
        'host_certificate'   => '-h',
        'principals'         => proc { |options| [ "-n",  options.join(",") ] },
        'cert_options'       => proc { |options| options.collect { |opt| ['-O', opt] } },
    }

    keygen_extra_args = []
    options.each do |name, values|
        if valid_options.has_key?(name)
            argspec = valid_options[name]
        else
            raise ArgumentError, ("ssh_sign_certificate(): unknown option `#{name}'")
        end

        if argspec.kind_of?(Array)
            keygen_extra_args << argspec[0] << sprintf(argspec[1], values)
        elsif argspec.kind_of?(String)
            keygen_extra_args << argspec
        elsif argspec.kind_of?(Proc)
            keygen_extra_args << argspec.call(values)
        end
    end

    unless File.exists?(signkey_file)
        raise ArgumentError, ("ssh_sign_certificate(): first argument (#{signkey_file}) needs to specify path to an existing signing key")
    end

    unless certificate_id.kind_of?(String)
        raise ArgumentError, ("ssh_sign_certificate(): second argument needs to be the certificate id")
    end

    unless public_key.kind_of?(String)
        raise ArgumentError, ("ssh_sign_certificate(): third argument needs to be a string containing public key")
    end

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

            keygen_command = [ 'ssh-keygen', '-q', '-s', signkey_file, '-I', certificate_id, keygen_extra_args, public_key_temp_file]
            keygen_command.flatten!


            debug "Executing #{keygen_command}"
            IO.popen(keygen_command.join(" ")) do |io|#, :err=>[:child, :out]) do |io|
                #FIXME: Implement error handling
                io.read
            end

            FileUtils.cp(certificate_temp_file, cache_file)
        end
    end

    return File.read(cache_file)
  end
end
