require "lib/pygments_renderer"
require "newrelic_rpm"

set :markdown_engine, :redcarpet
set :markdown, :renderer => PygmentsRenderer, :tables => true, :autolink => true, :gh_blockcode => true, :fenced_code_blocks => true,
    :no_intra_emphasis => true, :strikethrough => true, :with_toc_data => true

activate :blog do |blog|
  blog.permalink = ":title"
  blog.layout = "post"
end

Time.zone = "London"

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

page "/", :layout => "index"
page "/feed.xml", :layout => false
page "/articles", :layout => "articles"

activate :directory_indexes

configure :build do
  activate :asset_hash, :exts => ['.js', '.css', '.png', '.gif', '.jpg', '.woff']
  activate :minify_css
  activate :minify_javascript
  activate :gzip
end
