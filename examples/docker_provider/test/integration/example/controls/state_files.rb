# frozen_string_literal: true

backend_state =
  attribute(
    "backend_state",
    {}
  )

<<<<<<< HEAD
=======
configured_state =
  attribute(
    "terraform_state",
    {}
  )

>>>>>>> add back docker provider example
control "state_files" do
  describe "the backend state file" do
    subject do
      file backend_state
    end

    it do
      is_expected.to exist
    end
  end
<<<<<<< HEAD
=======

  describe "the configured state file" do
    subject do
      file configured_state
    end

    it do
      is_expected.to_not exist
    end
  end
>>>>>>> add back docker provider example
end
