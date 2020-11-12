require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'yaml'
  gem 'json'
end

PACKS = YAML.load_file 'packs.yaml'

detailed_packs = PACKS.map{ |pack_name, pack|
  pack['name'] = pack_name
  pack['url'] = "https://github.com/#{pack['repo']}"

  data = JSON.parse File.read "data/#{pack_name}.json"
  pack['icons_amount'] = data.size

  pack
}

File.open('detailed_packs.yml', 'w') {|f| f.write detailed_packs.to_yaml }
