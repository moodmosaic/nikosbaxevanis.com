require "redcarpet"
require "stringex"
require 'builder'

set :markdown_engine, :redcarpet
set :markdown       , :fenced_code_blocks => true, :smartypants => true
set :css_dir        , 'stylesheets'
set :js_dir         , 'javascripts'
set :images_dir     , 'images'

activate :livereload

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :cache_buster
end

class Article

  @@dir         = "#{Dir.pwd}/source/data/articles/"
  @@date_range  = @@dir.size..@@dir.size+10

  attr_accessor :published, :year, :month, :day, :title, :file, :url, :slug, :date, :type, :body, :categories

  def initialize(resource)

    @resource  = resource
    @published = resource.metadata[:page]["published"]

    if @published == nil then
      @published = true
    end

    # assumption that the file is named correctly!
    date_parts = resource.source_file[@@date_range].split('-')

    @year  = date_parts[0]
    @month = date_parts[1]
    @day   = date_parts[2]
    @date  = Date.new(@year.to_i, @month.to_i, @day.to_i)
    @title = resource.metadata[:page]["title"]
    @file  = resource.source_file["#{Dir.pwd}/source".size..-1].sub(/\.erb$/, '').sub(/\.markdown$/, '')
    @url   = "/blog/#{@year}/#{@month}/#{@day}/#{@title.to_url}"
    @slug  = resource.metadata[:page]["slug"] || "" 
    @type  = :article

    raw_categories = resource.metadata[:page]["categories"] || []
    if raw_categories.is_a? String then
      @categories = raw_categories.split(' ')
    else
      @categories = raw_categories
    end
  end

  def body 
    @resource.render(:layout => false)
  end

  def self.dir 
    @@dir
  end
end

class Note

  @@dir         = "#{Dir.pwd}/source/data/notes/"
  @@date_range  = @@dir.size..@@dir.size+10

  attr_accessor :published, :year, :month, :day, :title, :file, :url, :slug, :date, :type, :body, :categories

  def initialize(resource)

    @resource  = resource
    @published = resource.metadata[:page]["published"]

    if @published == nil then
      @published = true
    end

    # assumption that the file is named correctly!
    date_parts = resource.source_file[@@date_range].split('-')

    @year  = date_parts[0]
    @month = date_parts[1]
    @day   = date_parts[2]
    @date  = Date.new(@year.to_i, @month.to_i, @day.to_i)
    @title = resource.metadata[:page]["title"]
    @file  = resource.source_file["#{Dir.pwd}/source".size..-1].sub(/\.erb$/, '').sub(/\.markdown$/, '')
    @url   = "/notes/#{@year}/#{@month}/#{@day}/#{@title.to_url}"
    @slug  = resource.metadata[:page]["slug"] || "" 
    @type  = :note

    raw_categories = resource.metadata[:page]["categories"] || []
    if raw_categories.is_a? String then
      @categories = raw_categories.split(' ')
    else
      @categories = raw_categories
    end
  end

  def body 
    @resource.render(:layout => false)
  end

  def self.dir 
    @@dir
  end
end

class Draft

  @@dir         = "#{Dir.pwd}/source/data/drafts/"
  @@date_range  = @@dir.size..@@dir.size+10

  attr_accessor :published, :year, :month, :day, :title, :file, :url, :slug, :date, :type, :body, :categories

  def initialize(resource)

    @resource  = resource
    @published = resource.metadata[:page]["published"]

    if @published == nil then
      @published = true
    end

    # assumption that the file is named correctly!
    date_parts = resource.source_file[@@date_range].split('-')

    @year  = date_parts[0]
    @month = date_parts[1]
    @day   = date_parts[2]
    @date  = Date.new(@year.to_i, @month.to_i, @day.to_i)
    @title = resource.metadata[:page]["title"]
    @file  = resource.source_file["#{Dir.pwd}/source".size..-1].sub(/\.erb$/, '').sub(/\.markdown$/, '')
    @url   = "/drafts/#{@year}/#{@month}/#{@day}/#{@title.to_url}"
    @slug  = resource.metadata[:page]["slug"] || "" 
    @type  = :draft

    raw_categories = resource.metadata[:page]["categories"] || []
    if raw_categories.is_a? String then
      @categories = raw_categories.split(' ')
    else
      @categories = raw_categories
    end
  end

  def body 
    @resource.render(:layout => false)
  end

  def self.dir 
    @@dir
  end
end

ready do

  articles    = []
  notes       = []
  drafts      = []

  sitemap.resources.each do |res| 
    case res.source_file 
    when /^#{Regexp.quote(Article.dir)}/
      article = Article.new(res)
      if article.published then
        articles.unshift article
        proxy "#{article.url}/index.html", article.file
      end
    when /^#{Regexp.quote(Note.dir)}/
      note = Note.new(res)
      if note.published then
        notes.unshift note
        proxy "#{note.url}/index.html", note.file
      end
    when /^#{Regexp.quote(Draft.dir)}/
      draft = Draft.new(res)
      if draft.published then
        drafts.unshift draft
        proxy "#{draft.url}/index.html", draft.file
      end
    end
  end

  zipped = (articles + notes).sort_by { |item| item.date }.reverse

  categories = zipped
    .flat_map { |entry| entry.categories }
    .uniq
    .sort_by { |category| category }

  categories_by_count = zipped
    .flat_map { |entry| entry.categories }
    .group_by { |entry| entry }
    .map      { |category, group| [category, group.count] }
    .sort_by  { |category, count| -count }

  proxy "/index.html"      , "/dashboard.html", :locals => {  }
  proxy "/blog/index.html" , "/blog.html"     , :locals => { :catalog => zipped, :categories => categories_by_count }  
  proxy "/notes/index.html", "/blog.html"     , :locals => { :catalog => notes   , :categories => categories_by_count }
  proxy "/drafts/index.html", "/blog.html"     , :locals => { :catalog => drafts   , :categories => categories_by_count }
  proxy "/feed/index.xml"  , "/feed.xml"      , :locals => { :items   => zipped }

  ignore "/dashboard.html"
  ignore "/blog.html"
  ignore "/notes.html"
  ignore "/drafts.html"
  ignore "/feed.xml"
  ignore "/data/*"
end