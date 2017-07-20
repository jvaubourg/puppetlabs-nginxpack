require 'spec_helper'

describe 'nginxpack::ssl::default' do

  # SSL_*_* TESTS

  context 'with cert and key from source' do
    let(:params) {{
      :ssl_cert_source => 'foo',
      :ssl_key_source  => 'bar',
    }}

    it do
      should contain_nginxpack__ssl__certificate('default').with(
        'ssl_cert_source'  => 'foo',
        'ssl_key_source'   => 'bar',
        'ssl_cert_content' => false,
        'ssl_key_content'  => false
      )
    end
  end

  context 'with cert and key from content' do
    let(:params) {{
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
    }}

    it do
      should contain_nginxpack__ssl__certificate('default').with(
        'ssl_cert_source'  => false,
        'ssl_key_source'   => false,
        'ssl_cert_content' => 'foo',
        'ssl_key_content'  => 'bar'
      )
    end
  end

  # GENERAL TESTS

  context 'with neither cert nor key' do
    it do
      should contain_file('/etc/nginx/ssl/default.key') \
        .with_content(/^MIIJQgIBADANBgkqhkiG9w0BAQEFAASCCS/)
    end

    it do
      should contain_file('/etc/nginx/ssl/default.pem') \
        .with_content(/^MIIFnDCCA4SgAwIBAgIJAIytPSWWG8P6MA0/)
    end

    it do
      should contain_file('/etc/nginx/sites-enabled/default_https') \
        .with_ensure('link') \
        .with_target('/etc/nginx/sites-available/default_https')
    end
  end

  context 'with cert and key' do
    let(:params) {{
      :ssl_cert_content => 'bar',
      :ssl_key_content  => 'foo',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/default_https')
    end

    it do
      should contain_file('/etc/nginx/sites-enabled/default_https') \
        .with_ensure('link') \
        .with_target('/etc/nginx/sites-available/default_https')
    end
  end
end
