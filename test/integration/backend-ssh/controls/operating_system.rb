# frozen_string_literal: true

control "operating_system" do
  describe os do
    its("family") { should eq "debian" }
    its("release") { should eq "18.04" }
  end
end
