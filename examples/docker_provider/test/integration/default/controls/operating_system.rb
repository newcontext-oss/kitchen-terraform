# frozen_string_literal: true

control 'operating_system' do
  describe 'the operating system' do
    subject { command('lsb_release -a').stdout }

    it('is Ubuntu') { is_expected.to match (/Ubuntu/) }
  end
end
