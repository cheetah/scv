%w(rubygems bundler/setup redcarpet tilt slim pp).each { |r| require r }

class HTMLwithGists < Redcarpet::Render::HTML
  def block_code(c, l)
    l == 'gist' ? "<script src='https://gist.github.com/#{c}.js'></script>" : c
  end
end

class Page

  RENDERER = Redcarpet::Markdown.new(HTMLwithGists, :fenced_code_blocks => true)
  ENTRIES_PATH = File.join(File.dirname(__FILE__), 'entries', '*.md')

  attr_reader :name, :headers, :tags

  def self.parse_all
    Dir[ENTRIES_PATH].map { |path| self.new(path) }
  end

  def initialize(path)
    @path = path
    @name = File.basename(path, '.md').downcase
    parse_page
  end

  def parse_page
    headers, @body = IO.read(@path).split(/\n\n/, 2)
    parse_headers(headers)
  end

  def parse_headers(headers)
    @headers = Hash[headers.split("\n").map do |h| 
      key, value = h.split(/:\s+/, 2)
      [key.downcase.to_sym, value]
    end]

    @tags = @headers.has_key?(:tags) ? @headers[:tags].split(/,\s+/) : []
  end

  def tagged?
    @tags.size > 0
  end

  def has_tag?(tag)
    @tags.include?(tag)
  end

  def html_path
    "#{@name}.html"
  end

  def render
    RENDERER.render(@body)
  end

end

class Templates < Hash

  TEMPLATES_PATH = File.join(File.dirname(__FILE__), 'templates')

  def initialize
    Dir[File.join(TEMPLATES_PATH, '*')].each do |template|
      self[File.basename(template, '.*').to_sym] = Tilt.new(template)
    end
  end

  def method_missing(name, *args, &blk)
    has_key?(name.to_sym) ? self[name.to_sym] : super(name, *args, &blk)
  end

end

class Generator

  def initialize
    @pages = Page.parse_all
    @views = Templates.new
  end

  def generate_posts
    @pages.each do |post|
      write_file(post.html_path) do
        @views.layout.render { @views.post.render(post) }
      end
    end
  end

  private
  def write_file(file, &block)
    IO.write("./static/#{file}", yield)
  end

end

g = Generator.new
g.generate_posts


















