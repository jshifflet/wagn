module Wagn::Set::Type::Basic

  def post_render(content)
    #warn "CALLED POST RENDER: #{content}"
    table_of_contents(content) || content
  end

  def table_of_contents(content)
    min = self.setting('table of contents').to_i
    return unless min and min > 0
    
    toc, dep = [], 1
    content.gsub!( /<(h\d)>(.*?)<\/h\d>/i ) do
      tag, value = $~[1,2]
      value = ActionView::Base.new.strip_tags(value).strip
      next if value.empty?
      item = { :value => value, :uri => URI.escape(value) }
      case tag.downcase
      when 'h1'
        item[:depth] = dep = 1; toc << item
      when 'h2'
        toc << []  if dep == 1
        item[:depth] = dep = 2; toc.last << item
      end
      %{<a name="#{item[:uri]}"></a>} + $MATCH
    end

    if toc.flatten.length >= min
      content.replace %{ <div class="table-of-contents"> <h5>Table of Contents</h5> } +
        make_table_of_contents_list(toc) + '</div>'+ content
    end
  end
  
  private

  def make_table_of_contents_list(items)
    list = items.collect do |i|
      Array === i ? make_table_of_contents_list(i) : %{<li><a href="##{i[:uri]}"> #{i[:value]}</a></li>}
    end.join("\n")
    "<ol>" + list + "</ol>"
  end
end

