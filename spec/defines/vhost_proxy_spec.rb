require 'spec_helper'

require_relative 'vhost_common_tests'
require_relative 'vhost_https_tests'

describe 'nginxpack::vhost::proxy' do
  let(:title) { 'foobar' }

  vhost_common_tests('_proxy')
  vhost_https_tests('_proxy')

  # UPLOAD_MAX_SIZE TESTS

  context 'with upload_max_size' do
    let(:params) {{
      :upload_max_size => '1G',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_proxy') \
        .with_content(/^\s*client_max_body_size\s+1G;$/)
    end
  end

  # TO_DOMAIN TESTS

  context 'with domain destination' do
    let(:params) {{
      :to_domain => 'foo.example.com',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_proxy') \
        .with_content(/^\s*proxy_pass\s+http:\/\/foo\.example\.com:80\/;/)
    end
  end

  context 'with no domain destination' do
    let(:params) {{
      :domains => [ 'foo.example.com' ],
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_proxy') \
        .with_content(/^\s*proxy_pass\s+http:\/\/foo\.example\.com:80\/;/)
    end
  end

  context 'with no domain destination and no domains (default)' do
    it do
      should contain_file('/etc/nginx/sites-available/foobar_proxy') \
        .with_content(/^\s*proxy_pass\s+http:\/\/localhost:80\/;/)
    end
  end

  # TO_HTTPS TESTS

  context 'with to_https' do
    let(:params) {{
      :to_https => true,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_proxy') \
        .with_content(/^\s*proxy_pass\s+https:\/\/localhost:443\/;/)
    end
  end

  # TO_PORT TESTS

  context 'with port destination' do
    let(:params) {{
      :to_port => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_proxy') \
        .with_content(/^\s*proxy_pass\s+http:\/\/localhost:8080\/;/)
    end
  end

  context 'with to_https and port destination' do
    let(:params) {{
      :to_https => true,
      :to_port  => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_proxy') \
        .with_content(/^\s*proxy_pass\s+https:\/\/localhost:8080\/;/)
    end
  end
end
