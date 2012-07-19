# SCV
SCV is a simply Sinatra-like Ruby DSL to generate static sites. It also contains markdown pages and blog posts parser.

### Approximate workflow
```
require 'scv'

set :static, File.join(settings.root, 'public')

page 'hello.html' do
  'Hello World'
end

page 'template.html' do
  @context = 'context'
  
  render :template, :layout => false
end

style 'style.css', :"sass/screen"


@pages = SCV::Page.parse_all

@pages.each do |page|
  page page.html_path do
    @page = page
    
    render :page
  end
end
```
### Current Status
Lazy development, absolutely not ready to use.