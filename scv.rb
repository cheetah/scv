%w(rubygems bundler/setup singleton redcarpet tilt slim pp).each { |r| require r }

module SCV

  class Settings < Hash
    include Singleton

    def initialize
      self[:root]   = File.expand_path(File.dirname(__FILE__))
      self[:views]  = File.join(root, 'views')
      self[:pages]  = File.join(root, 'pages', '*.md')
      self[:static] = File.join(root, 'static')
    end

    def method_missing(name, *args, &blk)
      has_key?(name.to_sym) ? self[name.to_sym] : super(name, *args, &blk)
    end
  end

  class HTMLwithGists < Redcarpet::Render::HTML
    def block_code(code, lang)
      lang == 'gist' ? "<script src='https://gist.github.com/#{code}.js'></script>" : code
    end
  end

  class Page
    RENDERER = Redcarpet::Markdown.new(HTMLwithGists, :fenced_code_blocks => true)

    attr_reader :name, :headers, :tags

    def self.parse_all
      Dir[Settings.instance.pages].map { |path| self.new(path) }
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

    def post?
      @headers.has_key?(:date)
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

  class Views < Hash
    def initialize
      Dir[File.join(Settings.instance.views, '**/*.*')].each do |template|
        self[File.basename(template, '.*').to_sym] = Tilt.new(template)
      end
    end

    def method_missing(name, *args, &blk)
      has_key?(name.to_sym) ? self[name.to_sym] : super(name, *args, &blk)
    end
  end

  module Helpers
    def settings
      Settings.instance
    end

    def set(key, value)
      Settings.instance[key.to_sym] = value
    end
  end

  module Application
    include Helpers

    def page(name, &block)
      write_file(name, &block)
    end

    def render(view, opts = {:layout => :layout})
      @views ||= Views.new

      if opts[:layout]
        @views[opts[:layout]].render(self) { @views[view].render(self) }
      else
        @views[view].render(self)
      end
    end

    private
    def write_file(file, &block)
      dirname = File.dirname("#{Settings.instance.static}/#{file}")
      Dir.mkdir(dirname) unless Dir.exist?(dirname)
      IO.write(File.join(Settings.instance.static, file), yield)
    end
  end

end

extend SCV::Application