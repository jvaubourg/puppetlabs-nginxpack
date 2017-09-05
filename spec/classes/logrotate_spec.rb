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
      should contain_file('/etc/logrotate.d/nginx')\
        .with_content(/^\s*rotate 52$/)
    end

    it do
      should contain_file('/etc/logrotate.d/nginx')\
        .with_content(/^\s*weekly$/)
    end
  end

  context 'with custom params' do
    let(:params) {{
      :enable    => true,
      :rotate    => 365,
      :frequency => 'daily',
    }}

    it do
      should contain_file('/etc/logrotate.d/nginx')\
        .with_content(/^\s*rotate #{params[:rotate]}$/)
    end

    it do
      should contain_file('/etc/logrotate.d/nginx')\
        .with_content(/^\s*#{params[:frequency]}$/)
    end
  end

  context 'with a martian value for rotate' do
    let(:params) {{
      :enable => true,
      :rotate => 'foo',
    }}

    it_raises 'a Puppet::Error'
  end

  context 'with a martian value for frequency' do
    let(:params) {{
      :enable    => true,
      :frequency => 'foo',
    }}

    it_raises 'a Puppet::Error', /is not supported for frequency/
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
