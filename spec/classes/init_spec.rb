require 'spec_helper'

describe 'nginxpack' do
  context 'with logrotate => true' do
    let(:params) { {:logrotate => true} }

    it { should include_class('nginxpack::logrotate') }
  end

  context 'with logrotate => false' do
    let(:params) { {:logrotate => false} }

    it { should_not include_class('nginxpack::logrotate') }
  end
end
