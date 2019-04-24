# Tests for the operating system

control 'os-release' do
  impact 1.0
  desc 'Checks to see that the Windows OS release is correct.'
  describe os.family do
    it { should eq 'windows' }
  end
  describe os.release do
    it { should eq '10.0.17763' }
  end
end

control 'training-user' do
  impact 1.0
  desc 'Checks for the training user'
  describe user('hashicorp') do
    it { should exist }
  end
end
