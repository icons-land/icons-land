# compact a `json-server`-compatible `db.json`

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'yaml'
  gem 'json'
end

PACKS = YAML.load_file 'packs.yaml'

db = {
  packs: [],
  icons: []
}

PACKS.each_pair do |pack_name, pack|
  pack['id'] = pack_name
  pack['name'] = pack_name
  pack['url'] = "https://github.com/#{pack['repo']}"

  icons = JSON.parse File.read "data/#{pack_name}.json"
  icons.each do |icon|
    icon['urls'] = {
      svg: "https://rawcdn.githack.com/#{pack['repo']}/#{pack['ver_tag']}/#{icon['svg_path']}"
    }

    icon['packId'] = pack['id']

    icon.delete 'svg_path'
    icon.delete 'objectID'
    icon.delete 'pack'

    db[:icons] << icon
  end

  db[:packs] << pack
end

File.open('db.json', 'w') {|f| f.write db.to_json }
