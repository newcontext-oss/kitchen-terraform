# frozen_string_literal: true

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

require "middleman-autoprefixer"
require "middleman-favicon-maker"
require "middleman-livereload"
require "middleman-syntax"
require "pathname"

activate :livereload

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

activate :syntax do |syntax|
  syntax.css_class = "syntax-highlight"
end

helpers do
  def read_example_file(language: "plaintext", path:, &block)
    ::Pathname
      .new(__FILE__)
      .join(
        "..",
        "examples",
        path
      )
      .open do |file|
      define_singleton_method :lines do
        file.read
      end

      code(
        language,
        &block
      )
    end
  end
end

page(
  "/*.xml",
  layout: false,
)

page(
  "/*.json",
  layout: false,
)

page(
  "/*.txt",
  layout: false,
)

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

configure :build do
  set(
    :http_prefix,
    "/kitchen-terraform/"
  )

  activate :minify_css
  activate :minify_javascript

  # See favicon_maker README for additional details
  activate :favicon_maker do |f|
    f.template_dir = "source/images"
    f.icons = {
      "kitchen_terraform_logo.png" => [
        { icon: "apple-touch-icon-180x180-precomposed.png" },
        { icon: "apple-touch-icon-152x152-precomposed.png" },
        { icon: "apple-touch-icon-144x144-precomposed.png" },
        { icon: "apple-touch-icon-120x120-precomposed.png" },
        { icon: "apple-touch-icon-114x114-precomposed.png" },
        { icon: "apple-touch-icon-76x76-precomposed.png" },
        { icon: "apple-touch-icon-72x72-precomposed.png" },
        { icon: "apple-touch-icon-60x60-precomposed.png" },
        { icon: "apple-touch-icon-57x57-precomposed.png" },
        { icon: "apple-touch-icon-precomposed.png", size: "57x57" },
        { icon: "apple-touch-icon.png", size: "57x57" },
        { icon: "favicon-196x196.png" },
        { icon: "favicon-160x160.png" },
        { icon: "favicon-96x96.png" },
        { icon: "favicon-32x32.png" },
        { icon: "favicon-16x16.png" },
        { icon: "favicon.png", size: "16x16" },
        { icon: "favicon.ico", size: "64x64,32x32,24x24,16x16" },
        { icon: "mstile-70x70.png", size: "70x70" },
        { icon: "mstile-144x144.png", size: "144x144" },
        { icon: "mstile-150x150.png", size: "150x150" },
        { icon: "mstile-310x310.png", size: "310x310" },
        { icon: "mstile-310x150.png", size: "310x150" },
      ],
    }
  end
end
