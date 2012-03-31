require 'rubygems'
require 'hpricot'
require 'open-uri'

$output_file = "index2.html"
$base_dir = "C:\\Users\\Brandon\\Desktop\\docs\\"
$index_file = "index.html"
$content_div_ID = "mainContent"
$next_inner_text = /Next Page/i
$page_count ||= 0

class Page
  attr_reader :url, :body, :next_page
  
  @filename = nil
  @url = nil
  @body = nil
  @next_page = nil
  
  def initialize(file)
    @filename = file
    @url = $base_dir + @filename
    
    
    @doc = Hpricot(open(@url))
    
    #determine the next page
    (@doc/".pagerButton/a").each { |a|
      if a.inner_text().match($next_inner_text) != nil
        @next_page = a['href']
        break
      end
    }
    
    convert_body()
  end
  
  def anchored_html()
    anchor = @filename.match(/(.*?)\.html$/i)[1]
    return "<a name=\"#{anchor}\">\r\n" + @body.to_html()
  end
  

  def convert_body()
    new_div_id = "#{$content_div_ID}#{$page_count += 1}"
    
    #Number the content div
    (@doc/"div").each { |div|
      if div['id'] != nil && div['id'] == $content_div_ID
        div['id'] = new_div_id
      end
    }
    
    #Remove everything except the content div
    @body = @doc/"div##{new_div_id}"
    
    
    #Change all of the anchors to link to the proper spot
    (@body/"a").each { |a|
      next if a['href'] == nil || a == nil
      (a['href']).match(/(.*?)\.html$/i)
      new_href = $1
      a['href'] = "##{new_href}"
    }
    
  end
end

current = Page.new($index_file)
f = open($base_dir + $output_file, 'w:utf-8')


front_page = Hpricot(open($base_dir + $index_file))

f.puts("<html>")
f.puts(front_page/"head")
f.puts("<body>")

begin
  f.puts(current.anchored_html())
  current = Page.new(current.next_page)
end while current.next_page != nil

f.puts("</body>")
f.puts("</html>")

