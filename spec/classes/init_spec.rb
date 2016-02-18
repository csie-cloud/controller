require 'spec_helper'
describe 'controller_node' do

  context 'with defaults for all parameters' do
    it { should contain_class('controller_node') }
  end
end
