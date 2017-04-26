# frozen_string_literal: true

control "curl_installed" do describe package "curl" do it do is_expected.to be_installed end end end
