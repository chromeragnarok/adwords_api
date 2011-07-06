$:.push File.expand_path("../lib", __FILE__)
require 'adwords_api/api_config'

gem_name = 'google-adwords-api'

description = "#{gem_name} provides an easy to use way to access " +
    "the AdWords API in Ruby.\nCurrently the following AdWords API versions " +
    "are supported:"
versions = AdwordsApi::ApiConfig.versions.map { |version| version.to_s }
versions.sort.each do |version|
  description += "\n  * #{version}"
end

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = gem_name
  s.version = AdwordsApi::ApiConfig::CLIENT_LIB_VERSION
  s.summary = 'Client library for the AdWords API.'
  s.description = description
  s.authors = ['Sergio Gomes']
  s.email = 'api.sgomes@gmail.com'
  s.homepage = 'http://code.google.com/p/google-api-ads-ruby/'
  s.require_path = 'lib'
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.add_dependency('google_ads_common', '~> 0.5.0')
end