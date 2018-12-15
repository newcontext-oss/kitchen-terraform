# frozen_string_literal: true

control "workspace one" do
  describe attribute "workspace" do
    it { should eq "one" }
  end
end
