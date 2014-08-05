require 'spec_helper'

describe 'nginxpack' do

  # LOGROTATE TESTS

  context 'with logrotate' do
    let(:params) {{
      :logrotate => true,
    }}

    it do
      should contain_class('nginxpack::logrotate') \
        .with_enable(true)
    end
  end

  context 'with no logrotate' do
    let(:params) {{
      :logrotate => false,
    }}

    it do
      should contain_class('nginxpack::logrotate') \
        .with_enable(false)
    end
  end

  # SSL_*_* TESTS

  context 'with default cert and key from source' do
    let(:params) {{
      :ssl_default_cert_source => 'foo',
      :ssl_default_key_source  => 'bar',
    }}

    it do
      should contain_class('nginxpack::ssl::default').with(
        'ssl_cert_source'  => 'foo',
        'ssl_key_source'   => 'bar',
        'ssl_cert_content' => false,
        'ssl_key_content'  => false
      )
    end
  end

  context 'with default cert and key from content' do
    let(:params) {{
      :ssl_default_cert_content => 'foo',
      :ssl_default_key_content  => 'bar',
    }}

    it do
      should contain_class('nginxpack::ssl::default').with(
        'ssl_cert_source'  => false,
        'ssl_key_source'   => false,
        'ssl_cert_content' => 'foo',
        'ssl_key_content'  => 'bar'
      )
    end
  end

  # HTTPS BLACKHOLE

  context 'with neither default cert nor key but default https blackhole' do
    let(:params) {{
      :default_https_blackhole => true,
    }}

    it do
      should contain_class('nginxpack::ssl::default').with(
        'ssl_cert_source'  => false,
        'ssl_key_source'   => false,
        'ssl_cert_content' => false,
        'ssl_key_content'  => false
      )
    end
  end

  context 'with neither default cert nor key and no default https blackhole' do
    let(:params) {{
      :default_https_blackhole => false,
    }}

    it do
      should_not contain_file('/etc/nginx/ssl/default.key')
    end

    it do
      should_not contain_file('/etc/nginx/ssl/default.pem')
    end

    it do
      should_not contain_file('/etc/nginx/sites-enabled/default_https')
    end
  end

  context 'with default cert/key from content and no default https blackhole' do
    let(:params) {{
      :default_https_blackhole  => false,
      :ssl_default_cert_content => 'foo',
      :ssl_default_key_content  => 'bar',
    }}

    it do
      expect {
        subject
      }.to raise_error(Puppet::Error, /Use a default certificate without/)
    end
  end

  context 'with default cert/key from source and no default https blackhole' do
    let(:params) {{
      :default_https_blackhole => false,
      :ssl_default_cert_source => 'foo',
      :ssl_default_key_source  => 'bar',
    }}

    it do
      expect {
        subject
      }.to raise_error(Puppet::Error, /Use a default certificate without/)
    end
  end

  # ENABLE_PHP TESTS

  context 'with enable_php' do
    let(:params) {{
      :enable_php => true,
    }}

    it do
      should contain_class('nginxpack::php::cgi') \
        .with_enable(true)
    end
  end

  context 'with no enable_php' do
    let(:params) {{
      :enable_php => false
    }}

    it do
      should contain_class('nginxpack::php::cgi') \
        .with_enable(false)
    end
  end

  # GENERAL TESTS

  context 'with defaults' do
    it do
      should contain_package('nginx')
    end

    it do
      should contain_service('nginx') \
        .with_ensure('running') \
        .with_enable(true)
    end

    it do
      should contain_file('/etc/nginx/sites-available/default')
    end

    it do
      should contain_file('/etc/nginx/sites-enabled/default') \
        .with_ensure('link') \
        .with_target('/etc/nginx/sites-available/default')
    end

    it do
      should contain_file('/etc/nginx/include/attacks.conf')
    end

    it do
      should contain_file('/etc/nginx/find_default_listen.sh') \
        .with_mode('0755')
    end

    it do
      should contain_file('/var/log/nginx/') \
        .with_mode('0770') \
        .with_owner('www-data') \
        .with_group('www-data')
    end

    it do
      should contain_file('/etc/nginx/ssl/') \
        .with_mode('0550') \
        .with_owner('www-data') \
        .with_group('www-data')
    end
  end
end
