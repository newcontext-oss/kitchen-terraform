# frozen_string_literal: true

control "no_outputs_defined" do
  describe "the Test Kitchen suite" do
    subject do
      1
    end

    it "converges successfully with no outputs defined" do
      is_expected.to eq 1
    end
  end
end
