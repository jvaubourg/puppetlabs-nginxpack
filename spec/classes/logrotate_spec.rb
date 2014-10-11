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

    it { should contain_file('/etc/logrotate.d/nginx').with_content(/^\s*rotate 52$/)}
    it { should contain_file('/etc/logrotate.d/nginx').with_content(/^\s*weekly$/)}
  end

  context 'with custom params' do
    let(:params) {{
      :enable    => true,
      :rotate    => '365',
      :frequency => 'daily',
    }}

    it { should contain_file('/etc/logrotate.d/nginx').with_content(/^\s*rotate #{params[:rotate]}$/)}
    it { should contain_file('/etc/logrotate.d/nginx').with_content(/^\s*#{params[:frequency]}$/)}
  end

  context 'with a martian value for rotate' do
    let(:params) {{
      :enable    => true,
      :rotate    => 'ET',
    }}

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /rotate is not a valid number/)
      }
    end
  end

  context 'with a martian value for frequency' do
    let(:params) {{
      :enable    => true,
      :frequency => 'ET',
    }}

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /is not supported for frequency/)
      }
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
