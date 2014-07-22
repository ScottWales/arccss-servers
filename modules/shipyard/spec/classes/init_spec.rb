require 'spec_helper'
describe 'shipyard' do

  context 'with defaults for all parameters' do
    it { should contain_class('shipyard') }
  end
end
