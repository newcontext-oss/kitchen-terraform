# frozen_string_literal: true

ruby "~> 2.5"

source "https://rubygems.org/" do
  gemspec

  group :kitchen do
    gem "bcrypt_pbkdf", "~> 1.0"
    gem "rbnacl", "~> 4.0"
    gem "rbnacl-libsodium", "~> 1.0"
  end

  group :test do
    gem "rake", "~> 12.3"
  end
end
