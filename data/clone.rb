# NOTE we're not using a git submodule based solution due to uninvestigated performance issue

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'yaml'
end

PACKS = YAML.load_file 'packs.yaml'

PACKS.each_pair do |pack_name, pack_data|
  # TODO won't override existing repo to newer version
  puts `cd vendor && git clone --depth 1 --branch #{pack_data['ver_tag']} https://github.com/#{pack_data['repo']} #{pack_name}`
end
