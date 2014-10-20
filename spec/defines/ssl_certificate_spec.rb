require 'spec_helper'

describe 'nginxpack::ssl::certificate' do
  let(:title) { 'foobar' }

  # SSL_*_* TESTS

  context 'with contents' do
    let(:params) {{
      :ssl_key_content  => 'foo',
      :ssl_cert_content => 'bar',
    }}

    it do
      should contain_file('/etc/nginx/ssl/foobar.pem') \
        .with_content('bar')
    end

    it do
      should contain_file('/etc/nginx/ssl/foobar.key') \
        .with_content('foo')
    end
  end

  context 'with sources' do
    let(:params) {{
      :ssl_key_source  => 'foo',
      :ssl_cert_source => 'bar',
    }}

    it do
      should contain_file('/etc/nginx/ssl/foobar.pem')
    end

    it do
      should contain_file('/etc/nginx/ssl/foobar.key')
    end
  end
 
  # SSL_*_* ERRORS TESTS

  context 'with cert source and content' do
    let(:params) {{
      :ssl_cert_source  => 'foo',
      :ssl_cert_content => 'bar',
    }}

    it do
      expect {
        subject
      }.to raise_error(Puppet::Error, /certificate but not the both/)
    end
  end

  context 'with key source and content' do
    let(:params) {{
      :ssl_key_source  => 'foo',
      :ssl_key_content => 'bar',
    }}

    it do
      expect {
        subject
      }.to raise_error(Puppet::Error, /certificate but not the both/)
    end
  end

  context 'with only cert' do
    let(:params) {{
      :ssl_cert_content => 'bar',
    }}

    it do
      expect {
        subject
      }.to raise_error(Puppet::Error, /Please define a cert_pem/)
    end
  end

  context 'with only key' do
    let(:params) {{
      :ssl_key_content => 'bar',
    }}

    it do
      expect {
        subject
      }.to raise_error(Puppet::Error, /Please define a cert_pem/)
    end
  end
end
