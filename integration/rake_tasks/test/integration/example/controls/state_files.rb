# frozen_string_literal: true

backend_state =
  attribute(
    "backend_state",
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
end
