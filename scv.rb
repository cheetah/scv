%w(rubygems bundler/setup redcarpet tilt slim pp).each { |r| require r }

module SCV

  class HTMLwithGists < Redcarpet::Render::HTML
    def block_code(code, lang)
      lang == 'gist' ? "<script src='https://gist.github.com/#{c}.js'></script>" : code
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

  module Application

    STATIC_PATH = File.join(File.dirname(__FILE__), 'static')

    def page(name, &block)
      IO.write("#{STATIC_PATH}/#{name}", yield)
    end

    def render(view, opts = {:layout => :layout})
      @views ||= Templates.new

      if opts[:layout]
        @views[opts[:layout]].render(self) { @views[view].render(self) }
      else
        @views[view].render(self)
      end
    end

  end

end

extend SCV::Application

@pages = SCV::Page.parse_all

page 'index.html' do
  'abc'
end

page 'post.html' do
  @post = @pages.last
  render :post
end

page 'post1.html' do
  @post = @pages.first
  render :post
end

page 'post2.html' do
  @post = @pages.first
  render :post
end


















