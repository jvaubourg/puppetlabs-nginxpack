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
        .with_ensure('file') \
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

  context 'with htpasswd and htpasswd_msg' do
    let(:params) {{
      :htpasswd     => 'foo:bar',
      :htpasswd_msg => 'barfoo',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/\s*auth_basic\s+"barfoo";/)
    end
  end

  context 'with htpasswd and htpasswd_msg with quotes' do
    let(:params) {{
      :htpasswd     => 'foo:bar',
      :htpasswd_msg => 'ba"rf"oo',
    }}

    it do
      should_not contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/\s*auth_basic\s+"ba\\"rf\\"oo";/)
    end
  end

  context 'with htpasswd_msg but no htpasswd' do
    let(:params) {{
      :htpasswd     => false,
      :htpasswd_msg => 'barfoo',
    }}

    it_raises 'a Puppet::Error', /You need to use htpasswd/
  end

  # FORBIDDEN TESTS

  context 'with forbidden' do
    let(:params) {{
      :forbidden => [ 'foo', 'bar' ],
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*location\s+~\s+foo\s+{\s+return\s+403;\s+}$/) \
        .with_content(/^\s*location\s+~\s+bar\s+{\s+return\s+403;\s+}$/)
    end
  end

  # LISTING TESTS

  context 'with listing' do
    let(:params) {{
      :listing => true,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*autoindex on;$/)
    end
  end

  # TRY_FILES TESTS

  context 'with try_files' do
    let(:params) {{
      :try_files => 'barfoo',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*try_files.+\s+barfoo;$/)
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
        .with_content(/^\s*index.+\s+index\.php/)
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

  # PHP_ACCEPTPATHINFO TESTS

  context 'with php_AcceptPathInfo and use_php' do
    let(:params) {{
      :use_php            => true,
      :php_AcceptPathInfo => true,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*fastcgi_split_path_info/) \
        .with_content(/^\s*fastcgi_param\s+PATH_INFO\s+\$fastcgi_path_info;$/)
    end
  end

  context 'with php_AcceptPathInfo but no use_php' do
    let(:params) {{
      :use_php            => false,
      :php_AcceptPathInfo => true,
    }}

    it do
      should_not contain_file('/etc/nginx/sites-available/foobar')
        .with_content(/fastcgi_split_path_info/)
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

  # FILES_DIR TESTS

  context 'with files_dir' do
    let(:params) {{
      :files_dir => '/foo/bar/',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*root \/foo\/bar\/;$/)
    end
  end

  context 'with no files_dir' do
    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*root \/var\/www\/foobar\/;$/)
    end
  end
end
