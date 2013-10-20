require 'spec_helper'

require_relative 'vhost_common_tests'

describe 'nginxpack::vhost::redirection' do
  let(:title) { 'foobar' }

  vhost_common_tests('_redirection')

  # TO_DOMAIN TESTS

  context 'with domain destination' do
    let(:params) {{
      :to_domain => 'foo.example.com',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_redirection') \
        .with_content(/^\s*rewrite.+http:\/\/foo\.example\.com:80\/\$1 permanent;/)
    end
  end

  context 'with no domain destination' do
    let(:params) {{
      :domains => [ 'foo.example.com' ],
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_redirection') \
        .with_content(/^\s*rewrite.+http:\/\/foo\.example\.com:80\/\$1 permanent;/)
    end
  end

  context 'with no domain destination and no domains' do
    it do
      should contain_file('/etc/nginx/sites-available/foobar_redirection') \
        .with_content(/^\s*rewrite.+http:\/\/localhost:80\/\$1 permanent;/)
    end
  end

  # TO_HTTPS TESTS

  context 'with to_https' do
    let(:params) {{
      :to_https => true,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_redirection') \
        .with_content(/^\s*rewrite.+https:\/\/localhost:443\/\$1 permanent;/)
    end
  end

  # TO_PORT TESTS

  context 'with port destination' do
    let(:params) {{
      :to_port => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_redirection') \
        .with_content(/^\s*rewrite.+http:\/\/localhost:8080\/\$1 permanent;/)
    end
  end

  context 'with to_https and port destination' do
    let(:params) {{
      :to_https => true,
      :to_port  => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar_redirection') \
        .with_content(/^\s*rewrite.+https:\/\/localhost:8080\/\$1 permanent;/)
    end
  end
end
