require 'spec_helper'

describe 'nginxpack::php::mod' do
  let(:title) { 'foobar' }

  # GENERAL TESTS

  context 'with defaults' do
    it do
      should contain_package('php7.3-foobar')
    end
  end
end
