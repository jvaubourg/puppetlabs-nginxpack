require 'spec_helper'

describe 'nginxpack::vhost::basic' do
  let(:title) { 'foobar' }

  # ENABLE TESTS

  context 'with enable' do
    let(:params) {{
      :enable => true,
    }}

    it do
      should contain_file('/etc/nginx/sites-enabled/foobar') \
        .with_ensure('link') \
        .with_target('/etc/nginx/sites-available/foobar')
    end
  end

  context 'with no enable' do
    let(:params) {{
      :enable => false,
    }}

    it do
      should contain_file('/etc/nginx/sites-enabled/foobar') \
        .with_ensure('absent')
    end
  end

  # HTTPS TESTS

  context 'with https (vhost)' do
    let(:params) {{
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*ssl\s+on;$/) \
        .with_content(/^\s*ssl_certificate\s+\/etc\/nginx\/ssl\/foobar\.pem;$/) \
        .with_content(/^\s*ssl_certificate_key\s+\/etc\/nginx\/ssl\/foobar\.key;$/)
    end
  end

  context 'with https (certificate from content)' do
    let(:params) {{
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
    }}

    it do
      should contain_nginxpack__ssl__certificate('foobar').with(
        'ssl_cert_content' => 'foo',
        'ssl_key_content'  => 'bar',
        'ssl_cert_source'  => false,
        'ssl_key_source'   => false,
      )
    end
  end

  context 'with https (certificate from source)' do
    let(:params) {{
      :https           => true,
      :ssl_cert_source => 'foo',
      :ssl_key_source  => 'bar',
    }}

    it do
      should contain_nginxpack__ssl__certificate('foobar').with(
        'ssl_cert_content'  => false,
        'ssl_key_content'   => false,
        'ssl_cert_source' => 'foo',
        'ssl_key_source'  => 'bar',
      )
    end
  end

  # DOMAINS TESTS

  context 'with 1 domain' do
    let(:params) {{
      :domains => [ 'foo.example.com' ],
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*server_name\s+foo\.example\.com;$/)
    end
  end

  context 'with 2 domains' do
    let(:params) {{
      :domains => [ 'foo.example.com', 'bar.example.com' ],
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*server_name\s+foo\.example\.com bar\.example\.com;$/)
    end
  end

  # IP & PORT TESTS

  context 'with ipv6 (default port)' do
    let(:params) {{
      :ipv6 => '2001:db8::42',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+\[2001:db8::42\]:80;$/)
    end
  end

  context 'with ipv4 (default port)' do
    let(:params) {{
      :ipv4 => '203.0.113.42',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+203\.0\.113\.42:80;$/)
    end
  end

  context 'with ipv6 and port' do
    let(:params) {{
      :ipv6 => '2001:db8::42',
      :port => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+\[2001:db8::42\]:8080;$/)
    end
  end

  context 'with ipv4 and port' do
    let(:params) {{
      :ipv4 => '203.0.113.42',
      :port => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+203\.0\.113\.42:8080;$/)
    end
  end

  context 'with ipv6 and https (default port)' do
    let(:params) {{
      :ipv6             => '2001:db8::42',
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+\[2001:db8::42\]:443;$/)
    end
  end

  context 'with ipv4 and https (default port)' do
    let(:params) {{
      :ipv4             => '203.0.113.42',
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+203\.0\.113\.42:443;$/)
    end
  end

  context 'with ipv6, https and port' do
    let(:params) {{
      :ipv6             => '2001:db8::42',
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
      :port             => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+\[2001:db8::42\]:8080;$/)
    end
  end

  context 'with ipv4, https and port' do
    let(:params) {{
      :ipv4             => '203.0.113.42',
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
      :port             => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+203\.0\.113\.42:8080;$/)
    end
  end

  context 'with no ip (default port)' do
    let(:params) {{ }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+\[::\]:80;$/)
    end

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+0\.0\.0\.0:80;$/)
    end
  end

  context 'with no ip and https (default port)' do
    let(:params) {{
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+\[::\]:443;$/)
    end

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+0\.0\.0\.0:443;$/)
    end
  end

  context 'with no ip and port' do
    let(:params) {{
      :port => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+\[::\]:8080;$/)
    end

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+0\.0\.0\.0:8080;$/)
    end
  end

  context 'with no ip, https and port' do
    let(:params) {{
      :https            => true,
      :ssl_cert_content => 'foo',
      :ssl_key_content  => 'bar',
      :port             => 8080,
    }}

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+\[::\]:8080;$/)
    end

    it do
      should contain_file('/etc/nginx/sites-available/foobar') \
        .with_content(/^\s*listen\s+0\.0\.0\.0:8080;$/)
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
        .with_ensure(/^file$/)
        .with_content(/^foo:bar$/)
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
        .with_ensure(/^absent$/)
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
end
