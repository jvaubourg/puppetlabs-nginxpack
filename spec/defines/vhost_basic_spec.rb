require 'spec_helper'

require_relative 'vhost_common_tests'
require_relative 'vhost_https_tests'

describe 'nginxpack::vhost::basic' do
  let(:title) { 'foobar' }
  
  vhost_common_tests()
  vhost_https_tests()

  # INJECTIONSAFE TESTS

  context 'with injectionsafe' do
    let(:params) {{
      :injectionsafe => true,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*include\s+\/etc\/nginx\/include\/attacks\.conf;$/)
    end
  end

  context 'with no injectionsafe' do
    let(:params) {{
      :injectionsafe => false,
    }}

    it do
      should_not contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/attacks\.conf/)
    end
  end

  # HTPASSWD TESTS

  context 'with htpasswd' do
    let(:params) {{
      :htpasswd => 'foo:bar',
    }}

    it do
      should contain_file('/etc/nginx/htpasswd/foobar') \
        .with_ensure('file')
        .with_content('foo:bar')
    end

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*auth_basic_user_file\s+\/etc\/nginx\/htpasswd\/foobar;$/)
    end
  end

  context 'with no htpasswd' do
    let(:params) {{
      :htpasswd => false,
    }}

    it do
      should contain_file('/etc/nginx/htpasswd/foobar') \
        .with_ensure('absent')
    end

    it do
      should_not contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/auth_basic_user_file/)
    end
  end

  # USE_PHP TESTS

  context 'with use_php' do
    let(:params) {{
      :use_php => true,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/fastcgi_pass/)
    end

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*index.*index.php/)
    end
  end

  context 'with no use_php' do
    let(:params) {{
      :use_php => false,
    }}

    it do
      should_not contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/fastcgi_pass/)
    end

    it do
      should_not contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*index.*index.php/)
    end
  end

  # UPLOAD_MAX_SIZE TESTS

  context 'with upload_max_size' do
    let(:params) {{
      :upload_max_size => '1G',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*client_max_body_size\s+1G;$/)
    end
  end
end
