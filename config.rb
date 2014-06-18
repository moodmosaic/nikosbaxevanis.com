require "redcarpet"
require "stringex"
require 'builder'

set :markdown_engine , :redcarpet
set :markdown        , :fenced_code_blocks => true, :smartypants => true
set :css_dir         , 'stylesheets'
set :js_dir          , 'javascripts'
set :images_dir      , 'images'

activate :livereload
activate :syntax

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :cache_buster
end

class Article

  @@dir         = "#{Dir.pwd}/source/data/blog/"
  @@date_range  = @@dir.size..@@dir.size+10

  attr_accessor :published, :year, :month, :day, :title, :file, :url, :slug, :date, :type, :body, :categories, :resource

  def initialize(resource)

    @resource  = resource
    @published = resource.metadata[:page]["published"]

    if @published == nil then
      @published = true
    end

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

class Screencast

  @@dir        = "#{Dir.pwd}/source/data/screencasts/"
  @@date_range = @@dir.size..@@dir.size+10

  attr_accessor :type, :date, :title, :subtitle, :file, :url, :screenshot, :body, :categories, :external

  def initialize(resource)

    @resource   = resource
    @title      = resource.metadata[:page]["title"]
    @file       = resource.source_file["#{Dir.pwd}/source".size..-1].sub(/\.erb$/, '').sub(/\.markdown$/, '')
    @screenshot = resource.metadata[:page]["screenshot"] || ""
    @external   = resource.metadata[:page]["external"] || false
    @sequence   = resource.metadata[:page]["sequence"]
    @date       = resource.metadata[:page]["date"]
    @subtitle   = resource.metadata[:page]["subtitle"] || ""
    @url        = if external then
      resource.metadata[:page]["url"]
    else
      "/screencasts/#{@sequence}-#{@title.to_url}"
    end
    @type       = :screencast

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

  articles = []
  screencasts = []

  sitemap.resources.each do |res|
    case res.source_file
    when /^#{Regexp.quote(Article.dir)}/
      article = Article.new(res)
      if article.published then
        articles.unshift article
        proxy "#{article.url}/index.html", article.file, :locals => { :article => article }
      end
    when /^#{Regexp.quote(Screencast.dir)}/
      screencast = Screencast.new(res)
      screencasts.unshift screencast
      if !screencast.external then
        proxy "#{screencast.url}/index.html", screencast.file, :locals => {:screencast => screencast}
      end
    end
  end

  zipped = (articles + screencasts).sort_by { |item| item.date }.reverse

  proxy "/index.html"              , "/dashboard.html"    , :locals => { :entries => zipped }
  proxy "/screencasts/index.html"  , "/thingies.html"     , :locals => { :entries => screencasts, :title => "Screencasts" }
  proxy "/blog/index.html"         , "/thingies.html"     , :locals => { :entries => articles,    :title => "Blog" }
  proxy "/feed/index.xml"          , "/feed.xml"          , :locals => { :items => zipped }
  proxy "/testimonials/index.html" , "/testimonials.html"

  categories = zipped
    .flat_map { |entry| entry.categories }
    .uniq
    .sort_by { |category| category }

  categories
    .each { |category|
      entries = zipped
        .select { |entry| entry.categories.include? category }
      proxy "/category/#{category.downcase.gsub(' ', '-')}/index.html",
            "/thingies.html" ,
            :locals => { :entries => entries, :title => category }
    }

  ignore "/feed.xml"
  ignore "/thingies.html"
  ignore "/dashboard.html"
  ignore "/screencasts.html"
  ignore "/data/*"
end
