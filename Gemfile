source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "#{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['~> 3.7.2']
end

group :unit_tests, :development do
  gem 'puppet', puppetversion
  gem 'metadata-json-lint'
  gem 'rake'

  gem 'puppet-lint', '~> 2.0'
  gem 'puppet-lint-unquoted_string-check', :require => false
  gem 'puppet-lint-empty_string-check', :require => false
  gem 'puppet-lint-leading_zero-check', :require => false
  gem 'puppet-lint-variable_contains_upcase', :require => false

  gem 'rspec'
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper', '>= 0.1.0'
  gem 'sshkey'
end

group :system_tests do
  gem 'beaker', '~> 2.0'
  gem 'beaker-rspec'
  gem 'pry'
end
