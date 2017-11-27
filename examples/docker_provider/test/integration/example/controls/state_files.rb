# frozen_string_literal: true

backend_state =
  attribute(
    "backend_state",
    {}
  )

configured_state =
  attribute(
    "terraform_state",
    {}
  )

control "state_files" do
  describe "the backend state file" do
    subject do
      file backend_state
    end

    it do
      is_expected.to exist
    end
  end

  describe "the configured state file" do
    subject do
      file configured_state
    end

    it do
      is_expected.to_not exist
    end
  end
end
