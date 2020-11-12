require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'yaml'
  gem 'json'
  gem 'front_matter_parser'

  gem 'byebug'
end

require './icon'

# def file_cdn_path repo, tag, path
#   "https://rawcdn.githack.com/#{repo}/#{tag}/#{path}"
# end

PACKS = YAML.load_file 'packs.yaml'

PACKS.each_pair do |pack_name, pack|
  pack['name'] = pack_name

  puts "handling #{pack['name']}"

  icons = []

  Dir.chdir "vendor/#{pack['name']}" do
    case pack['name']
    when 'font-awesome'
      data = YAML.load_file 'metadata/icons.yml'
      data.each do |icon_name, icon_data|
        svg_path =  case true
                    when icon_data['styles'].include?('solid') # solid as default style
                      "svgs/solid/#{icon_name}.svg"
                    else
                      "svgs/#{icon_data['styles'].first}/#{icon_name}.svg"
                    end

        icons << Icon.new(
          pack: pack,
          name: icon_name,
          tags: icon_data['search']['terms'],
          svg_path: svg_path
        ).data_for_algolia
      end
    when 'bootstrap-icons'
      Dir['icons/*.svg'].each do |svg_path|
        name = File.basename svg_path, '.svg'
        doc_path = "docs/content/icons/#{name}.md"
        doc_meta = FrontMatterParser::Parser.parse_file(doc_path).front_matter

        icons << Icon.new(
          pack: pack,
          name: name,
          tags: doc_meta['tags'],
          svg_path: svg_path
        ).data_for_algolia
      end
    when 'material-design-icons'
      Dir['src/*'].each do |category_path|
        category = category_path.split('/').last
        Dir["src/#{category}/*"].each do |icon_path|
          name = icon_path.split('/').last
          svg_path = "#{icon_path}/materialicons/24px.svg"

          icons << Icon.new(
            pack: pack,
            name: name,
            tags: [category],
            svg_path: svg_path
          ).data_for_algolia
        end
      end
    when 'ionicons'
      data = JSON.parse File.read 'src/data.json'
      data['icons'].each do |icon|
        name = icon['name']
        svg_path = "src/svg/#{name}.svg"

        icons << Icon.new(
          pack: pack,
          name: name,
          tags: icon['tags'],
          svg_path: svg_path
        ).data_for_algolia
      end
    when 'octicons'
      data = JSON.parse File.read 'keywords.json'
      data.each_pair do |name, tags|
        svg_path = "icons/#{name}-24.svg"

        icons << Icon.new(
          pack: pack,
          name: name,
          tags: tags,
          svg_path: svg_path
        ).data_for_algolia
      end
    when 'css.gg'
      data = JSON.parse File.read 'icons/all.json'
      data.each_pair do |name, data|
        icons << Icon.new(
          pack: pack,
          name: name,
          tags: [],
          svg_path: "icons/svg/#{name}.svg"
        ).data_for_algolia
      end
    when 'feather'
      data = JSON.parse File.read 'src/tags.json'
      data.each_pair do |name, tags|
        svg_path = "icons/#{name}.svg"
        icons << Icon.new(
          pack: pack,
          name: name,
          tags: tags,
          svg_path: svg_path,
        ).data_for_algolia
      end
    when 'carbon-icons'
      data = YAML.load_file "packages/icons/icons.yml"
      data.each do |icon_data|
        name = icon_data['name']
        svg_path = "packages/icons/src/svg/32/#{name}.svg"
        icons << Icon.new(
          pack: pack,
          name: name,
          tags: icon_data['aliases'],
          svg_path: svg_path
        ).data_for_algolia
      end
    when 'typicons'
      data = YAML.load_file 'config.yml'
      data['glyphs'].each do |icon_data|
        name = icon_data['css']
        icons << Icon.new(
          pack: pack,
          name: name,
          tags: icon_data['search'],
          svg_path: "src/svg/#{name}.svg"
        ).data_for_algolia
      end
    when 'vscode-codicons'
      Dir['src/icons/*.svg'].each do |svg_path|
        name = File.basename svg_path, '.svg'
        icons << Icon.new(
          pack: pack,
          name: name,
          tags: [],
          svg_path: svg_path
        ).data_for_algolia
      end
    when 'simple-icons'
      # NOTE not using data file since not corresponding names
      # e.g. .net -> dot-net.svg
      # data = JSON.parse File.load '_data/simple-icons.json'

      Dir['icons/*.svg'].each do |svg_path|
        name = File.basename svg_path, '.svg'
        icons << Icon.new(
          pack: pack,
          name: name,
          tags: [],
          svg_path: svg_path
        ).data_for_algolia
      end
    else
      raise "Unknownpack: #{pack_name}"
    end
  end

  File.open "data/#{pack_name}.json", 'w' do |file|
    file.write icons.to_json
  end
end
