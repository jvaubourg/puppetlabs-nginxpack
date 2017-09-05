def vhost_common_tests(suffix = '')

  # ENABLE TESTS

  context 'with enable' do
    let(:params) {{
      :enable => true,
    }}

    it do
      should contain_file("/etc/nginx/sites-enabled/foobar#{suffix}") \
        .with_ensure('link') \
        .with_target("/etc/nginx/sites-available/foobar#{suffix}")
    end
  end

  context 'with no enable' do
    let(:params) {{
      :enable => false,
    }}

    it do
      should contain_file("/etc/nginx/sites-enabled/foobar#{suffix}") \
        .with_ensure('absent')
    end
  end

  # DOMAINS TESTS

  context 'with 1 domain' do
    let(:params) {{
      :domains => [ 'foo.example.com' ],
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*server_name\s+foo\.example\.com;$/)
    end
  end

  context 'with 2 domains' do
    let(:params) {{
      :domains => [ 'foo.example.com', 'bar.example.com' ],
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*server_name\s+foo\.example\.com bar\.example\.com;$/)
    end
  end

  # IP & PORT TESTS

  context 'with ipv6 (default port)' do
    let(:params) {{
      :ipv6 => '2001:db8::42',
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+\[2001:db8::42\]:80;$/)
    end
  end

  context 'with ipv4 (default port)' do
    let(:params) {{
      :ipv4 => '203.0.113.42',
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+203\.0\.113\.42:80;$/)
    end
  end

  context 'with ipv6 and port' do
    let(:params) {{
      :ipv6 => '2001:db8::42',
      :port => 8080,
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+\[2001:db8::42\]:8080;$/)
    end
  end

  context 'with ipv4 and port' do
    let(:params) {{
      :ipv4 => '203.0.113.42',
      :port => 8080,
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+203\.0\.113\.42:8080;$/)
    end
  end

  context 'with no ip (default port)' do
    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+\[::\]:80;$/)
    end

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+0\.0\.0\.0:80;$/)
    end
  end

  context 'with no ip and port' do
    let(:params) {{
      :port => 8080,
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+\[::\]:8080;$/)
    end

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+0\.0\.0\.0:8080;$/)
    end
  end

  context 'with ipv6 but no ipv6only' do
    let(:params) {{
      :ipv6     => '2001:db8::42',
      :ipv6only => false,
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+0\.0\.0\.0:80;$/)
    end
  end

  context 'with ipv6 and port but no ipv6only' do
    let(:params) {{
      :ipv6     => '2001:db8::42',
      :ipv6only => false,
      :port     => 8080,
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+0\.0\.0\.0:8080;$/)
    end
  end

  context 'with ipv6 and ipv6only' do
    let(:params) {{
      :ipv6     => '2001:db8::42',
      :ipv6only => true,
    }}

    it do
      should_not contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+0\.0\.0\.0:80;$/)
    end
  end

  context 'with ipv4 but no ipv4only' do
    let(:params) {{
      :ipv4     => '203.0.113.42',
      :ipv4only => false,
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+\[::\]:80;$/)
    end
  end

  context 'with ipv4 and port but no ipv4only' do
    let(:params) {{
      :ipv4     => '203.0.113.42',
      :ipv4only => false,
      :port     => 8080,
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+\[::\]:8080;$/)
    end
  end

  context 'with ipv4 and ipv4only' do
    let(:params) {{
      :ipv4     => '203.0.113.42',
      :ipv4only => true,
    }}

    it do
      should_not contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*listen\s+\[::\]:80;$/)
    end
  end

  if suffix != '_redirection' then
    context 'with ipv6 and https (default port)' do
      let(:params) {{
        :ipv6             => '2001:db8::42',
        :https            => true,
        :ssl_cert_content => 'foo',
        :ssl_key_content  => 'bar',
      }}

      it do
        should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
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
        should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
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
        should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
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
        should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
          .with_content(/^\s*listen\s+203\.0\.113\.42:8080;$/)
      end
    end

    context 'with no ip and https (default port)' do
      let(:params) {{
        :https            => true,
        :ssl_cert_content => 'foo',
        :ssl_key_content  => 'bar',
      }}

      it do
        should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
          .with_content(/^\s*listen\s+\[::\]:443;$/)
      end

      it do
        should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
          .with_content(/^\s*listen\s+0\.0\.0\.0:443;$/)
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
        should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
          .with_content(/^\s*listen\s+\[::\]:8080;$/)
      end

      it do
        should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
          .with_content(/^\s*listen\s+0\.0\.0\.0:8080;$/)
      end
    end
  end

  # ADD CONFIG TESTS

  context 'with add config (from content)' do
    let(:params) {{
      :add_config_content => 'foo',
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*include\s+\/etc\/nginx\/include\/foobar#{suffix}\.conf;/)
    end

    it do
      should contain_file("/etc/nginx/include/foobar#{suffix}\.conf") \
        .with_content('foo')
    end
  end

  context 'with add config (from source)' do
    let(:params) {{
      :add_config_source => 'foo',
    }}

    it do
      should contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*include\s+\/etc\/nginx\/include\/foobar#{suffix}\.conf;/)
    end

    it do
      should contain_file("/etc/nginx/include/foobar#{suffix}\.conf")
    end
  end

  context 'with no add config' do
    it do
      should_not contain_file("/etc/nginx/sites-available/foobar#{suffix}") \
        .with_content(/^\s*include\s+\/etc\/nginx\/include\/foobar#{suffix}\.conf;/)
    end
  end

  # ADD CONFIG ERRORS TESTS

  context 'with add config source and content' do
    let(:params) {{
      :add_config_content => 'foo',
      :add_config_source  => 'bar',
    }}

    it_raises 'a Puppet::Error', /add_config, but not both/
  end

  context 'with ipv6only and ipv4only' do
    let(:params) {{
      :ipv6only => true,
      :ipv4only => true,
    }}

    it_raises 'a Puppet::Error', /Using ipv6only with ipv4only/
  end

  context 'with ipv6only and ipv4' do
    let(:params) {{
      :ipv6only => true,
      :ipv4     => '203.0.113.42',
    }}

    it_raises 'a Puppet::Error', /Defining an IPv4 with ipv6only/
  end

  context 'with ipv4only and ipv6' do
    let(:params) {{
      :ipv4only => true,
      :ipv6     => '2001:db8::42',
    }}

    it_raises 'a Puppet::Error', /Defining an IPv6 with ipv4only/
  end
end
