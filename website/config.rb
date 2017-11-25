# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :livereload

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

activate :syntax do |syntax|
  syntax.css_class = "syntax-highlight"
end

page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

configure :build do
  set :http_prefix, '/kitchen-terraform/'

  activate :minify_css
  activate :minify_javascript
end
