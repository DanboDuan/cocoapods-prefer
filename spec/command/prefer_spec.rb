require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Prefer do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ prefer }).should.be.instance_of Command::Prefer
      end
    end
  end
end

