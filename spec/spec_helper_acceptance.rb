require 'beaker-rspec'
 
hosts.each do |host|
  # Install Puppet
  on host, install_puppet
end
 
RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = module_root.split('-').last
 
  # Readable test descriptions
  c.formatter = :documentation
 
  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => module_root, :module_name => module_name)
  end
end
