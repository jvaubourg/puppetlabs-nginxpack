require 'spec_helper'

describe 'nginxpack::ssl::certificate' do
  let(:title) { 'foobar' }

  # SSL_*_* TESTS

  context 'with contents' do
    let(:params) {{
      :ssl_key_content     => 'foo',
      :ssl_cert_content    => 'bar',
      :ssl_dhparam_content => '1337',
    }}

    it do
      should contain_file('/etc/nginx/ssl/foobar.pem') \
        .with_content('bar')
    end

    it do
      should contain_file('/etc/nginx/ssl/foobar.key') \
        .with_content('foo')
    end

    it do
      should contain_file('/etc/nginx/ssl/foobar_dhparam.pem') \
        .with_content('1337')
    end
  end

  context 'with sources' do
    let(:params) {{
      :ssl_key_source     => 'foo',
      :ssl_cert_source    => 'bar',
      :ssl_dhparam_source => '1337',
    }}

    it do
      should contain_file('/etc/nginx/ssl/foobar.pem')
    end

    it do
      should contain_file('/etc/nginx/ssl/foobar.key')
    end

    it do
      should contain_file('/etc/nginx/ssl/foobar_dhparam.pem')
    end
  end

  # SSL_*_* ERRORS TESTS

  context 'with cert source and content' do
    let(:params) {{
      :ssl_cert_source  => 'foo',
      :ssl_cert_content => 'bar',
    }}

    it_raises 'a Puppet::Error', /certificate, but not both/
  end

  context 'with key source and content' do
    let(:params) {{
      :ssl_key_source  => 'foo',
      :ssl_key_content => 'bar',
    }}

    it_raises 'a Puppet::Error', /certificate, but not both/
  end

  context 'with only cert' do
    let(:params) {{
      :ssl_cert_content => 'bar',
    }}

    it_raises 'a Puppet::Error', /Please, define a cert_pem/
  end

  context 'with only key' do
    let(:params) {{
      :ssl_key_content => 'bar',
    }}

    it_raises 'a Puppet::Error', /Please, define a cert_pem/
  end
end
