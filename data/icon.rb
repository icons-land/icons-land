class Icon
  def initialize pack:, style: 'default', name:, tags:, svg_path:
    @pack = pack
    @style = style
    @name = name
    @tags = tags
    @svg_path = svg_path

    @id = "#{pack['name']}|#{pack['ver_tag']}|#{name}|#{style}"
  end

  def data_for_algolia
    {
      objectID: @id,
      pack: @pack,
      name: @name,
      tags: @tags,
      svg_path: @svg_path,
    }
  end
end
