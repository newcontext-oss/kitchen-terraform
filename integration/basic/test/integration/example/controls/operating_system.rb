# frozen_string_literal: true

control "operating_system" do
  desc "This control validates the platform family of the operating system."

  describe os.family do
    it do
      should eq "debian"
    end
  end
end
