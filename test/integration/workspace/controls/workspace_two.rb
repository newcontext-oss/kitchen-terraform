# frozen_string_literal: true

control "workspace two" do
  describe attribute "workspace" do
    it { should eq "two" }
  end
end
