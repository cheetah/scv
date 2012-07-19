# -*-ruby-*-

require 'rake'
require 'digest/sha1'

task :next do
  print "Title: "
  title = $stdin.gets.chomp

  now = Time.now
  slug_name = title.gsub(/\s+/, '-').gsub("'", '').gsub(/[()]/, '').gsub(':', '').downcase
  slug = "#{now.strftime('%Y-%m-%d')}-#{slug_name}"
  id = Digest::SHA1.hexdigest(slug)[0,5]

  filename = "pages/#{slug}.md"
  contents = <<HERE
title: #{title}
date:  #{now.strftime('%Y-%m-%d %H:%M:%S')}
id:    #{id}

HERE

  open(filename, "w+") do |f|
    f.write(contents)
  end

  Kernel.exec(ENV['EDITOR'], filename)
  
end