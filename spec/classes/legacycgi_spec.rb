require 'spec_helper'

describe 'nginxpack::legacycgi' do

  # ENABLE TESTS

  context 'with enable' do
    let(:params) {{
      :enable => true,
    }}

    it do
      should contain_package('fcgiwrap') \
        .with_ensure('present')
    end

    it do
      should contain_service('fcgiwrap')
    end
  end

  context 'with no enable' do
    let(:params) {{
      :enable => false,
    }}

    it do
      should contain_package('fcgiwrap') \
        .with_ensure('absent')
    end

    it do
      should_not contain_service('fcgiwrap')
    end
  end

end
