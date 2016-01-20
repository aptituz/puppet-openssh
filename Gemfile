source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 2.7']
end

gem 'metadata-json-lint'
gem 'rake'
# newer versions have a bug that cause ignore patterns not to work
# http://stackoverflow.com/questions/27138893/puppet-lint-ignoring-the-ignore-paths-option
gem 'puppet-lint', '~> 1.0.1'
gem 'rspec'
gem 'rspec-puppet'
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet', puppetversion
gem 'beaker', '~> 2.0'
gem 'beaker-rspec', :require => false
gem 'pry'
