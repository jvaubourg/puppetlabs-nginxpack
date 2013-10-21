require 'spec_helper'

describe 'nginxpack::logrotate' do

  # ENABLE TESTS

  context 'with enable' do
    let(:params) {{
      :enable => true,
    }}

    it do
      should contain_package('logrotate')
    end

    it do
      should contain_package('psmisc')
    end

    it do
      should contain_file('/etc/logrotate.d/nginx')
    end
  end

  context 'with no enable' do
    let(:params) {{
      :enable => false,
    }}

    it do
      should_not contain_package('logrotate')
    end

    it do
      should_not contain_package('psmisc')
    end

    it do
      should contain_file('/etc/logrotate.d/nginx') \
        .with_ensure('absent')
    end
  end

end
