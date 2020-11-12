# requires an env `ALGOLIA_SECRET`

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'dotenv'
  gem 'yaml'
  gem 'json'
  gem 'algolia'
end

require 'dotenv/load'

PACKS = YAML.load_file 'packs.yaml'
CLIENT = Algolia::Search::Client.create '1EO21A8JUS', ENV['ALGOLIA_SECRET']
INDEX = CLIENT.init_index 'icons'

PACKS.each_pair do |pack_name, pack_data|
  puts "indexing #{pack_name}"

  icons = JSON.parse File.read "data/#{pack_name}.json"
  INDEX.save_objects icons
end
