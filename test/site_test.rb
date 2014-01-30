require 'set'
require 'uri'
require 'nokogiri'
require 'open-uri'
require 'colorize'

def crawl_site(starting_at)
  starting_uri = URI.parse(starting_at)
  seen_pages   = Set.new 
  gists        = Set.new
  crawl_page   = ->(page_uri, coming_from_uri) do
    unless seen_pages.include?(page_uri)
      seen_pages << page_uri
      begin
        doc   = Nokogiri.HTML(open(page_uri))
        hrefs = doc.css('a[href]').map  { |a| a['href'] }
        imgs  = doc.css('img[src], iframe[src]').map { |img| img['src'] }
        links = hrefs + imgs
        uris  = links.map    { |href| URI.join(page_uri, href) rescue nil }.compact # Make these URIs, throwing out problem ones like mailto:
                     .select { |uri| uri.host == starting_uri.host }                # Pare it down to only those pages that are on the same site        
                     .each   { |uri| uri.fragment = nil }                           # Remove #foo fragments so that sub-page links aren't differentiated
                     .each   { |uri| crawl_page.call(uri, page_uri) }               # Recursively crawl the child URIs
      rescue OpenURI::HTTPError
        warn "✗".red + " #{page_uri}"
        warn "    ↳ #{coming_from_uri}"
      end
    end
  end

  crawl_page.call( starting_uri, starting_uri )
end

crawl_site('http://localhost:4567')

puts "Done!".green