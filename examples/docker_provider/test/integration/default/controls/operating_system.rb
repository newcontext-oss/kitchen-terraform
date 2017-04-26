# frozen_string_literal: true

control "operating_system" do
  describe "the operating system" do
    subject do command("lsb_release -a").stdout end

    it "is Ubuntu" do is_expected.to match /Ubuntu/ end
  end
end
