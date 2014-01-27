---
layout: false
---
xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "moodmosaic - A modern full-stack programmer's notes and ideas."
  xml.subtitle "Published works of Nikos Baxevanis"
  xml.author { xml.name "Nikos Baxevanis" }
  xml.updated Time.parse(Time.now.to_s).iso8601
  xml.link "href" => "http://nikosbaxevanis.com/", "rel" => "alternate"
  xml.link "href" => "http://nikosbaxevanis.com/feed/", "rel" => "self"
  xml.id "http://nikosbaxevanis.com/"

  items.each do |item|
    xml.entry do
      xml.title item.title
      xml.link "rel" => "alternate", "href" => item.url
      xml.id "http://nikosbaxevanis.com" + item.url
      xml.updated Time.parse(item.date.to_s).iso8601
      xml.author { xml.name "Nikos Baxevanis" }
      xml.content item.body, "type" => "html"
    end
  end
end